#!/usr/bin/env bash
# Purge any AWS Secrets Manager secrets that are in the PendingDeletion state
# at the well-known paths managed by infra/envs/prod/secrets.tf.
#
# Why this exists: AWS forbids creating a new secret with a name that is
# currently scheduled for deletion. After a `terraform destroy`, the four
# app secrets enter a 7-day recovery window and block any subsequent
# `terraform apply` until the window expires or the secrets are forcibly
# removed. This script is opt-in (gated by the infra-apply workflow input
# `purge_pending_secrets`) and only acts on secrets whose `DeletedDate` is
# set, leaving healthy secrets untouched.
#
# Idempotent: safe to re-run. Exits 0 even if no secrets were pending.
# Requires: AWS CLI v2, credentials already exported (the workflow does this
# via aws-actions/configure-aws-credentials before invoking).

set -euo pipefail

# Hardcoded list - matches `${local.secret_prefix}/...` in
# infra/envs/prod/secrets.tf. Update both places if the naming changes.
SECRETS=(
  "/java-app/prod/db/app-user"
  "/java-app/prod/admin"
  "/java-app/prod/jwt"
  "/java-app/prod/ses"
)

for s in "${SECRETS[@]}"; do
  # describe-secret returns non-zero (ResourceNotFoundException) when the
  # secret has never existed; treat that as "nothing to purge".
  deleted=$(aws secretsmanager describe-secret \
    --secret-id "$s" \
    --query 'DeletedDate' \
    --output text 2>/dev/null || echo "MISSING")

  case "$deleted" in
    MISSING|None)
      echo "skip  $s (not pending deletion)"
      ;;
    *)
      echo "purge $s (DeletedDate=$deleted)"
      aws secretsmanager delete-secret \
        --secret-id "$s" \
        --force-delete-without-recovery >/dev/null
      ;;
  esac
done

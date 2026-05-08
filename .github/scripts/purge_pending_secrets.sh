#!/usr/bin/env bash
# Purge any AWS Secrets Manager secrets that are in the PendingDeletion state
# under the project's well-known prefix (set by infra/envs/prod/secrets.tf).
#
# Why this exists: AWS forbids creating a new secret whose name is currently
# scheduled for deletion. After `terraform destroy`, the four app secrets
# enter a 7-day recovery window and block any subsequent `terraform apply`
# until the window expires or the secrets are forcibly removed.
#
# Strategy: ListSecrets with --include-planned-deletion under the prefix,
# then ForceDelete every match whose DeletedDate is non-null. This handles
# leftovers under variant names and avoids the missing-vs-healthy ambiguity
# that a per-name DescribeSecret had: DescribeSecret returns success on a
# healthy secret and ResourceNotFoundException on a missing one, both of
# which look identical when stderr is suppressed, so genuine pending-
# deletion entries can hide behind a misconfigured region or profile.
#
# Idempotent: safe to re-run. Exits 0 if no secrets are pending.
# Requires: AWS CLI v2 (--include-planned-deletion was added in v2).
# Credentials must already be exported (the workflow handles this via
# aws-actions/configure-aws-credentials).
#
# Env overrides:
#   SECRET_PREFIX  Defaults to /java-app/prod/. Change for other envs/projects.

set -euo pipefail

PREFIX="${SECRET_PREFIX:-/java-app/prod/}"

# Visibility: print exactly which AWS account, region, and principal this
# run is targeting. If this disagrees with where the pending-deletion
# secrets actually live, no purge will happen and Terraform will keep
# failing with InvalidRequestException.
echo "AWS context for purge:"
aws sts get-caller-identity --output table || {
  echo "ERROR: sts get-caller-identity failed; credentials are not configured." >&2
  exit 1
}
echo "Region:       ${AWS_REGION:-${AWS_DEFAULT_REGION:-<unset>}}"
echo "Prefix:       ${PREFIX}"
echo

# ListSecrets filters: Key=name does a prefix-style match on the Name field.
# --include-planned-deletion is required to surface pending-deletion entries.
# The query keeps only those with DeletedDate set.
mapfile -t PENDING < <(
  aws secretsmanager list-secrets \
    --include-planned-deletion \
    --filters "Key=name,Values=${PREFIX}" \
    --query 'SecretList[?DeletedDate!=`null`].Name' \
    --output text \
    | tr '\t' '\n' \
    | sed '/^$/d'
)

# For diagnostic completeness, also list every secret under the prefix
# (healthy or pending) so an operator can compare against expectations.
echo "All secrets under ${PREFIX} (healthy and pending):"
aws secretsmanager list-secrets \
  --include-planned-deletion \
  --filters "Key=name,Values=${PREFIX}" \
  --query 'SecretList[].[Name,DeletedDate]' \
  --output table || true
echo

if [ "${#PENDING[@]}" -eq 0 ]; then
  echo "No secrets under ${PREFIX} are in PendingDeletion. Nothing to purge."
  exit 0
fi

echo "Found ${#PENDING[@]} pending-deletion secret(s):"
printf '  %s\n' "${PENDING[@]}"
echo

for s in "${PENDING[@]}"; do
  echo "purge $s"
  aws secretsmanager delete-secret \
    --secret-id "$s" \
    --force-delete-without-recovery >/dev/null
done

echo "Purge complete."

# ADR 0005 - Secret rotation strategy

## Status
Accepted (initial). The "Destroy/recreate lifecycle" subsection below is
overridden in dev environments by ADR 0007; see that ADR for the
`recovery_window_in_days = 0` rationale and the production-revert path.

## Context
Secrets must be rotatable without service disruption.

## Decision
Per-secret approach:

| Secret                       | Rotation                                                                       |
| ---------------------------- | ------------------------------------------------------------------------------ |
| `/java-app/prod/db/master`   | RDS-managed, AWS rotates default 7 days.                                       |
| `/java-app/prod/db/app-user` | Manual: rotate with a Flyway migration that runs `ALTER USER ... IDENTIFIED BY` and updates the secret in the same change set. App reconnects on restart. |
| `/java-app/prod/jwt`         | Rotate by writing a new value, then triggering an instance refresh. Existing tokens become invalid; clients re-login. |
| `/java-app/prod/admin`       | Rotate by writing a new value; the running app already has the previous admin record (seed is idempotent and only inserts when absent). |
| `/java-app/prod/ses`         | Rotate freely; backend re-reads at restart.                                    |

## Consequences
- JWT rotation is disruptive (re-login required). Acceptable for v1.
- A future iteration can support "previous + current" key rolling by
  storing both in the secret JSON and trying each on parse.

### Destroy/recreate lifecycle

All four app-managed secrets in `infra/envs/prod/secrets.tf`
(`db/app-user`, `admin`, `jwt`, `ses`) are created with
`recovery_window_in_days = 7`. Decision rationale:

- 7 is the AWS minimum non-zero recovery window. Anything smaller
  (`0`) means immediate force-deletion with no safety net, which is
  rejected for production secrets even though the values are
  reproducible from Terraform inputs.
- 30 (the AWS default) is too long: it blocks any re-apply of the env
  for a month after `terraform destroy`, which conflicts with the
  bootstrap-and-redeploy flow used during environment rebuilds.

Re-applying within the 7-day window is the standard cycle. The block
that AWS raises (`InvalidRequestException: ... already scheduled for
deletion`) is handled by an opt-in workflow input
`purge_pending_secrets` on `infra-apply.yml`, which executes
`.github/scripts/purge_pending_secrets.sh` to force-delete only those
secrets currently in `PendingDeletion`. The procedure is documented in
`docs/auxiliary/operations_guide/04-operations.md`. Operators are
expected to use the workflow toggle rather than ad-hoc AWS CLI on every
cycle, so the unblock path is auditable in CI logs.

This decision applies only to secrets whose values are deterministically
reproducible from Terraform inputs or `random_password`. Long-lived
secrets bound to external state (third-party API keys, customer-bound
material) must not adopt this pattern; they require a different
recovery window and a non-destructive unblock path.

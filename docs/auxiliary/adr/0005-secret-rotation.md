# ADR 0005 - Secret rotation strategy

## Status
Accepted (initial)

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

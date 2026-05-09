# ADR 0008 - RDS MySQL 8.0 -> 8.4 LTS upgrade

## Status
Accepted

## Context
Amazon RDS announced standard-support deprecation for MySQL 8.0. The 8.0
line moves to RDS Extended Support pricing on the deprecation cutover and
is removed from standard maintenance shortly thereafter. (unverified -
exact dates differ per region; check the AWS RDS MySQL release calendar
in the target region with `aws rds describe-db-engine-versions
--engine mysql --include-all`.)

The reference implementation in this repo runs MySQL 8.0 on RDS via the
`terraform-aws-modules/rds/aws` module. The same engine pin is replicated
across the local docker-compose stack (`mysql:8.0`), the Testcontainers
integration test (`mysql:8.0`), the JDBC Testcontainers URL
(`jdbc:tc:mysql:8.0:///...`), and the Hibernate dialect
(`org.hibernate.dialect.MySQL8Dialect`). All of these surfaces must move
in lockstep.

The two upgrade targets RDS exposes are:

- MySQL 8.4 LTS (long-term support; standard 5+3-year cycle).
- MySQL 9.x innovation track (rapid release; ~2-year support window per
  release).

## Decision
Move every surface to MySQL 8.4 LTS in a single change.

Rationale:

- 8.4 is an LTS line. Picking it preserves multi-year support after this
  change lands and avoids re-doing the same upgrade against the 9.x
  innovation cadence.
- 8.4 is a single major-version step from 8.0. RDS supports the 8.0 -> 8.4
  in-place upgrade. 8.0 -> 9.x would force two hops or a fresh-instance
  cutover. (unverified - check `aws rds describe-db-engine-versions
  --engine mysql --engine-version 8.0 --query 'DBEngineVersions[0].ValidUpgradeTarget'`
  for the authoritative upgrade-target list at apply time.)
- 8.4 keeps the parameter set we currently tune (`character_set_server`,
  `collation_server=utf8mb4_0900_ai_ci`, `slow_query_log`,
  `long_query_time`, `log_output`, `max_connections`). All six remain
  valid in `mysql8.4` family parameter groups.
- 8.4 ships `caching_sha2_password` as the default authentication plugin,
  same as 8.0. The 8.4 release no longer auto-loads
  `mysql_native_password`; this is the only behavioural change of any
  consequence for our connection model and is mitigated below.

### Engine version string
`var.rds_engine_version` defaults to `"8.4"`. The bare major lets RDS
pick the latest 8.4.x patch. Pin a full `M.m.p` only if a specific
patch is required (CVE response, regression rollback).

### In-place upgrade execution
Two new arguments on `module.rds`:

- `allow_major_version_upgrade = true`. AWS rejects a major version bump
  unless this is set. Flip back to `false` in a follow-up PR after the
  upgrade has landed in prod, so accidental engine bumps from a future
  variable change cannot proceed unattended.
- `apply_immediately = true`. The upgrade runs as soon as `terraform
  apply` completes rather than queueing to the configured maintenance
  window. RDS still triggers the standard major-upgrade prep (snapshot,
  read-only window, restart). Operator must take a manual snapshot
  before running apply; the in-place RDS-managed snapshot is automatic
  but slower to restore from than a named manual one.

### Parameter group
The parameter group is replaced, not edited in place: a parameter
group's `family` is immutable, and a `mysql8.0` family group cannot be
attached to an 8.4 instance. The Terraform-managed group is renamed
from `${name_prefix}-mysql8` to `${name_prefix}-mysql84`, which causes
Terraform to create the new group and detach the old one in a single
plan. The DB instance switches to the new group on the same apply.

### Default option group
RDS provides per-major default option groups under the well-known name
`default:mysql-{major}-{minor}`, but the named group is created
**lazily** on the first instance provisioning with that engine version
in an account/region. Verified 2026-05-08 against the sandbox account
in `us-east-1`: `aws rds describe-option-groups --engine-name mysql
--major-engine-version 8.4` returns an empty list because no 8.4
instance has been created in the account yet, while the equivalent
query for 8.0 returns `default:mysql-8-0`.

Hard-pinning `option_group_name = "default:mysql-8-4"` in the module
input would cause `terraform apply` to fail with `OptionGroupNotFoundFault`
on first apply. The fix in `rds.tf` is to omit the `option_group_name`
argument entirely; the AWS provider treats it as `Computed` when
unset, the RDS API attaches the engine default (creating it if
necessary), and no drift appears on subsequent plans. The codebase
does not use a custom option group, so no options need to be ported.

### Auth-plugin migration
The `appuser` MySQL account is now provisioned by
`aws_lambda_function.db_bootstrap` (see
`infra/envs/prod/db_bootstrap.tf`) and not by Flyway. The Lambda runs
`CREATE USER IF NOT EXISTS ... IDENTIFIED WITH caching_sha2_password`
followed by an idempotent `ALTER USER ... IDENTIFIED WITH
caching_sha2_password` on every invocation, so the user is always
provisioned with the 8.4-compatible plugin regardless of whether the
account existed before. `terraform_data.db_bootstrap` invokes the
Lambda on RDS replacement or on app-user secret rotation, so the
auth-plugin alignment survives `terraform destroy` + `terraform apply`
cycles. Consequences post-bootstrap:

- A fresh apply against an empty 8.4 instance: Lambda creates `appuser`
  with `caching_sha2_password`. No operator action.
- A pre-existing `appuser` with `mysql_native_password`: the Lambda's
  `ALTER USER ... IDENTIFIED WITH caching_sha2_password BY ?` flips the
  plugin and (re)sets the password to the current secret value. No
  operator action.
- A pre-existing `appuser` already on `caching_sha2_password`: the
  `ALTER USER` is a no-op for the plugin field and idempotently re-sets
  the password to the current secret value (matches it on every run).
  No operator action.

The legacy manual conversion in runbook RB-DB-001
(`docs/auxiliary/operations_guide/runbooks/2026-05-08_appuser_auth_plugin_conversion.md`)
remains valid as a fall-back when the Lambda is not available (for
example during a partial Terraform apply that created RDS but failed
before `terraform_data.db_bootstrap` ran). Re-trigger the Lambda
without a full apply via:

```bash
aws lambda invoke \
  --profile <profile> --region us-east-1 \
  --function-name java-app-prod-db-bootstrap \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{}' \
  /tmp/db_bootstrap_out.json
cat /tmp/db_bootstrap_out.json
```

### Hibernate dialect
`org.hibernate.dialect.MySQL8Dialect` is deprecated in Hibernate 6.x
(shipped with Spring Boot 3.x). It still functions against an 8.4
server but emits a deprecation warning on every startup. Replaced with
`org.hibernate.dialect.MySQLDialect`, which auto-detects the server
version from JDBC metadata. No schema or query semantics change.

### Driver
`mysql-connector-j` is managed by the Spring Boot 3.5.0 BOM. The
BOM-pinned 8.x driver speaks the 8.4 protocol unchanged. No `pom.xml`
edit.

### Testcontainers + local docker-compose
Both pin the `mysql` image tag explicitly. Bumped from `8.0` to `8.4`
in `app/docker/docker-compose.local.yml`, `MigrationsIT.java`, and
`application-test.yml`'s `jdbc:tc:mysql:8.4:///...` URL.

## Consequences

- One-shot downtime when `terraform apply` runs. Multi-AZ failover
  reduces but does not eliminate the read-only window during the major
  upgrade. Plan a maintenance window even though `apply_immediately =
  true` removes the AWS-side queue delay.
- The parameter group rename triggers a parameter group replacement in
  the plan output. This is expected. Terraform will not delete the
  outgoing group while it is still attached; it attaches the new group
  first, then destroys the old one.
- Backups, performance insights, slow-query logs, encryption-at-rest,
  and the `delete_automated_backups` / `skip_final_snapshot` /
  deletion-protection wiring are unchanged.
- `allow_major_version_upgrade = true` stays set after this change. A
  follow-up PR must flip it back to `false`. Until that PR lands, a
  later edit to `var.rds_engine_version` could cause an unintended
  major bump.

## Manual rotation procedure for `appuser`
Automatic rotation is intentionally out of scope (consistent with ADR
0005 and ADR 0007 stance on rotation Lambdas in this dev-only env).
To rotate the `appuser` password manually:

1. Generate a new password with `aws secretsmanager get-random-password
   --password-length 32 --exclude-characters '"@/\\'`. Copy the value.
2. Update the Secrets Manager entry:
   ```bash
   aws secretsmanager put-secret-value \
     --secret-id ${local.secret_prefix}/db/app-user \
     --secret-string "$(jq -n --arg u appuser --arg p '<NEW>' \
        '{username:$u, password:$p}')"
   ```
3. Apply the same password to the live MySQL user (run as `dbadmin`
   using the master secret):
   ```sql
   ALTER USER 'appuser'@'%' IDENTIFIED WITH caching_sha2_password BY '<NEW>';
   FLUSH PRIVILEGES;
   ```
4. Trigger an ASG instance refresh to make running EC2s pick up the
   new secret value. The user-data script reads the secret on boot;
   long-lived instances retain the old credential until they recycle.

## Post-upgrade follow-ups

After the 8.0 -> 8.4 apply has succeeded in prod and the smoke test
passes (`https://java.talorlik.com/actuator/health` returns
`status=UP`, app logs show no JDBC reconnect storm, RDS console shows
the instance available on engine `mysql 8.4.x`), open a follow-up PR
that flips the upgrade gate back off:

- File: `infra/envs/prod/rds.tf`
- Line: `68` (under the `module "rds"` block, immediately after the
  `instance_class` argument).
- Change:
  ```hcl
  -  allow_major_version_upgrade = true
  +  allow_major_version_upgrade = false
  ```
- Same PR: drop the explanatory comment block above the line (lines
  65-67) since the dev-cycle reasoning no longer applies. Optionally
  remove `apply_immediately = true` (line 73) and the comment block
  above it (lines 70-72) - that flag is dev-only convenience and a
  production-safe default queues changes to the maintenance window.
- Validation: `terraform_validate`, `tflint`, `checkov` (must stay
  green; checkov has no rule on either flag), and `terraform_plan`
  against the prod backend - the plan should show `~ update in-place`
  on `module.rds.aws_db_instance.this[0]` with the only change being
  `allow_major_version_upgrade: true -> false` (and `apply_immediately`
  if also removed).
- Apply via the standard `infra-apply.yml` workflow.

A pre-existing `appuser` row pinned to `mysql_native_password` will
break authentication after the engine bump. Pre-flight check is
runbook `docs/auxiliary/operations_guide/runbooks/2026-05-08_appuser_auth_plugin_conversion.md`.
Run that runbook BEFORE applying the engine upgrade, not after.

## Rollback
If the upgrade misbehaves:

1. Restore from the manual pre-upgrade snapshot to a new instance
   identifier. Do not flip `engine_version` back; major-version
   downgrades are not supported on RDS.
2. Update DNS / SSM (`/java-app/prod/db/endpoint`) to the restored
   instance's address.
3. Trigger an ASG instance refresh so EC2s pick up the new endpoint.
4. Open a follow-up issue documenting the failure mode before
   retrying the upgrade.

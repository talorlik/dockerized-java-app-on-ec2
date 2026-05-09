# Runbook - Convert `appuser` MySQL auth plugin to `caching_sha2_password`

- ID: `RB-DB-001`
- Created: 2026-05-08
- Trigger: pre-flight before any RDS major-version upgrade past MySQL 8.0.
  Re-usable any time the live `appuser` row in `mysql.user` is pinned to
  `mysql_native_password` (which 8.4 and later no longer auto-load).
- Severity: blocking. After the engine bump, an `appuser` row still pinned
  to `mysql_native_password` cannot authenticate, and the app loses DB
  access until this runbook is executed.
- Estimated time: 5-10 minutes plus SSM session warm-up.
- Prereqs (operator workstation):
  - AWS CLI v2 with profile or env that can assume the deployment role
    (`secretsmanager:GetSecretValue` on the master + app-user secrets,
    `ssm:GetParameter`, `ssm:StartSession` on the EC2 ASG instances,
    `ec2:DescribeInstances`, `rds:DescribeDBInstances`).
  - Session Manager plugin for AWS CLI (`session-manager-plugin --version`).
  - `jq`.
  - `mysql` client v8 (Homebrew: `brew install mysql-client`).

## When to use this runbook

Primary path: `aws_lambda_function.db_bootstrap` (see
`infra/envs/prod/db_bootstrap.tf`) provisions `appuser` automatically
on every relevant `terraform apply` and on every app-user secret
rotation, with `caching_sha2_password`. Use this runbook only when the
Lambda is not the right tool:

- Manual triage during a partial-apply incident, before
  `terraform_data.db_bootstrap` has run.
- Pre-flight audit when investigating an unrelated DB auth failure.
- Disaster recovery from a snapshot that predates the Lambda.

For a normal rotation, write the new secret value and either re-apply
Terraform (the secret-version change triggers the Lambda) or invoke
the function directly:

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

## Decision tree

1. Run the audit (step 4 below).
2. Plugin column shows `caching_sha2_password` -> done. No change needed.
3. Plugin column shows `mysql_native_password` -> proceed with steps 5-7,
   OR invoke the bootstrap Lambda above (it runs the same `ALTER USER`
   idempotently and is the preferred path when the Lambda is available).
4. Empty result (no `appuser` row) -> invoke the bootstrap Lambda. The
   Lambda's `CREATE USER IF NOT EXISTS` will provision the account. If
   the Lambda is unavailable for some reason, follow steps 5-7 manually
   (the SQL is identical; the Lambda just automates it).

## Procedure

### 1. Resolve the RDS endpoint
```bash
DB_HOST=$(aws ssm get-parameter \
  --region us-east-1 \
  --name /java-app/prod/db/endpoint \
  --with-decryption \
  --query Parameter.Value --output text)
echo "DB_HOST=$DB_HOST"
```

### 2. Pull the RDS-managed master password
```bash
MASTER_SECRET_ARN=$(aws rds describe-db-instances \
  --region us-east-1 \
  --db-instance-identifier java-app-prod-mysql \
  --query 'DBInstances[0].MasterUserSecret.SecretArn' --output text)

MASTER_PW=$(aws secretsmanager get-secret-value \
  --region us-east-1 \
  --secret-id "$MASTER_SECRET_ARN" \
  --query SecretString --output text \
  | jq -r '.password')

[ -n "$MASTER_PW" ] || { echo "no master password retrieved"; return 1; }
```

### 3. Open an SSM port-forward to the private RDS endpoint
The DB is in private subnets. Forward through any healthy EC2 instance
in the ASG. Run this in **terminal A** and leave it running:
```bash
INSTANCE_ID=$(aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Project,Values=java-app" \
            "Name=tag:Environment,Values=prod" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)

aws ssm start-session \
  --region us-east-1 \
  --target "$INSTANCE_ID" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "host=$DB_HOST,portNumber=3306,localPortNumber=13306"
```
Leave open. All `mysql` commands below run in **terminal B**.

### 4. Audit the `appuser` auth plugin
```bash
mysql -h 127.0.0.1 -P 13306 -u dbadmin -p"$MASTER_PW" -e \
  "SELECT user, host, plugin FROM mysql.user WHERE user='appuser';"
```
Map the result to the decision tree above.

### 5. Pull the `appuser` password from Secrets Manager
Only run if step 4 returned `mysql_native_password`. Reuses the password
already in the secret; no new value is generated.
```bash
APP_PW=$(aws secretsmanager get-secret-value \
  --region us-east-1 \
  --secret-id /java-app/prod/db/app-user \
  --query SecretString --output text \
  | jq -r '.password')
[ -n "$APP_PW" ] || { echo "no app password retrieved"; return 1; }
```

### 6. Convert the auth plugin
```bash
mysql -h 127.0.0.1 -P 13306 -u dbadmin -p"$MASTER_PW" <<SQL
ALTER USER 'appuser'@'%' IDENTIFIED WITH caching_sha2_password BY '$APP_PW';
FLUSH PRIVILEGES;
SQL
```
The password value is unchanged; only the plugin column flips. The app
does not need a restart - existing pooled connections survive, and new
connections negotiate the new plugin transparently.

### 7. Verify
```bash
mysql -h 127.0.0.1 -P 13306 -u dbadmin -p"$MASTER_PW" -e \
  "SELECT user, host, plugin FROM mysql.user WHERE user='appuser';"
```
Expected: `appuser | % | caching_sha2_password`.

### 8. Tear down the port-forward
Ctrl-C in terminal A. SSM session ends; the EC2 instance stays in the ASG.

## Failure modes

| Symptom                                                                 | Cause                                                                                            | Action |
|-------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|--------|
| `Access denied for user 'dbadmin'@'<ip>'`                               | Master password was rotated since the last secret read; secret cache is stale.                   | Re-run step 2; if still failing, force a rotation: `aws rds modify-db-instance --apply-immediately --master-user-password-secret`. |
| `Can't connect to MySQL server on '127.0.0.1' (61)`                     | Port-forward in terminal A died, or `localPortNumber` collision with another local mysqld.       | Re-run step 3; if 13306 is taken, pick another free port and pass it through to step 4-7. |
| `ERROR 1396 (HY000): Operation ALTER USER failed for 'appuser'@'%'`     | Row does not exist for that user/host combination.                                               | Re-run step 4 to inspect; if the user has a different `host` value (`'localhost'`, `'10.%'`, etc.) adjust the ALTER. |
| App throws `Public Key Retrieval is not allowed` after the conversion   | App's JDBC URL lacks `allowPublicKeyRetrieval=true` (or `useSSL=true`). Repo uses `useSSL=true` so this should not trigger; if it does, the connection is being downgraded somewhere. | Confirm `app/backend/src/main/resources/application.yml` still has `useSSL=true`. |

## Rollback
If the new plugin breaks something unforeseen, revert to native:
```sql
ALTER USER 'appuser'@'%' IDENTIFIED WITH mysql_native_password BY '$APP_PW';
FLUSH PRIVILEGES;
```
This only works while the engine is still 8.0. After the 8.4 upgrade
lands, `mysql_native_password` is no longer auto-loaded; revert is not
available without `INSTALL COMPONENT 'file://component_mysql_native_password'`,
which RDS does not expose. Do not roll the engine back; restore from the
manual pre-upgrade snapshot per ADR 0008's rollback section if needed.

## Manual snapshot cleanup

RDS manual snapshots have no native TTL and persist until deleted.
After a successful upgrade and burn-in window, drop the pre-upgrade
snapshot (and any sibling artifacts) to stop accruing storage cost
(~$0.095/GB-month in `us-east-1`, unverified).

Replace `<profile>` with the AWS profile that has
`rds:DescribeDBSnapshots` and `rds:DeleteDBSnapshot` against the
deployment account.

### List manual snapshots for the instance
```bash
aws rds describe-db-snapshots \
  --profile <profile> \
  --region us-east-1 \
  --db-instance-identifier java-app-prod-mysql \
  --snapshot-type manual \
  --query "DBSnapshots[].[DBSnapshotIdentifier,SnapshotCreateTime,Status,AllocatedStorage]" \
  --output table
```

### Delete a specific manual snapshot
```bash
aws rds delete-db-snapshot \
  --profile <profile> \
  --region us-east-1 \
  --db-snapshot-identifier java-app-prod-mysql-pre-8-4
```
Idempotent on AWS side - deleting an already-deleted snapshot returns
`DBSnapshotNotFoundFault`. The CLI exits non-zero; safe to ignore for
cleanup scripts.

### Delete every manual snapshot for the instance
Use only when you have verified no snapshot is still needed for
rollback. Lists, prompts per id, deletes on `y`.
```bash
aws rds describe-db-snapshots \
  --profile <profile> \
  --region us-east-1 \
  --db-instance-identifier java-app-prod-mysql \
  --snapshot-type manual \
  --query "DBSnapshots[].DBSnapshotIdentifier" \
  --output text \
| tr '\t' '\n' \
| while read -r SNAP; do
    [ -z "$SNAP" ] && continue
    read -r -p "delete $SNAP? [y/N] " ANS
    [ "$ANS" = "y" ] || continue
    aws rds delete-db-snapshot \
      --profile <profile> \
      --region us-east-1 \
      --db-snapshot-identifier "$SNAP"
  done
```

### Delete all manual snapshots whose id matches a prefix
Useful when you took multiple pre-upgrade snapshots (e.g.
`java-app-prod-mysql-pre-8-4-take1`, `-take2`).
```bash
PREFIX="java-app-prod-mysql-pre-8-4"
aws rds describe-db-snapshots \
  --profile <profile> \
  --region us-east-1 \
  --db-instance-identifier java-app-prod-mysql \
  --snapshot-type manual \
  --query "DBSnapshots[?starts_with(DBSnapshotIdentifier,'$PREFIX')].DBSnapshotIdentifier" \
  --output text \
| tr '\t' '\n' \
| while read -r SNAP; do
    [ -z "$SNAP" ] && continue
    aws rds delete-db-snapshot \
      --profile <profile> \
      --region us-east-1 \
      --db-snapshot-identifier "$SNAP"
  done
```

### Verify nothing is left
```bash
aws rds describe-db-snapshots \
  --profile <profile> \
  --region us-east-1 \
  --db-instance-identifier java-app-prod-mysql \
  --snapshot-type manual \
  --query "length(DBSnapshots)" \
  --output text
```
Expected: `0` (or whatever count of intentionally-retained snapshots).

### Safety rails
- `--snapshot-type manual` is mandatory. Omitting it includes
  automated snapshots, which `delete-db-snapshot` cannot delete and
  which RDS lifecycles per the instance's `backup_retention_period`.
- Never delete a snapshot referenced by a `db-instance-restore` you
  have not yet validated. Restore + smoke test first, then delete.
- Cross-region copies: `describe-db-snapshots` returns only the
  region you query. If the snapshot was copied to another region for
  DR, repeat per region.

### Bulk cleanup via the destroy workflow
For full-stack teardown (not a targeted snapshot sweep), the
`infra-destroy.yml` GitHub Actions workflow exposes a
`delete_manual_snapshots` boolean input (default `true`). When set, the
workflow runs the prefix-batch deletion above as its post-destroy
step 6. Use this only when destroying the env entirely; the safer
manual sweeps are the per-id and prefix commands earlier in this
section.

## Audit trail
- Action target: `mysql.user` row for `('appuser', '%')`.
- Recorded by: AWS CloudTrail (RDS API calls), MySQL general log
  (`enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]`
  in `infra/envs/prod/rds.tf`), and the app's own `audit_events` table is
  unaffected by this change.

## Related
- ADR 0008 - `docs/auxiliary/adr/0008-mysql-8-4-upgrade.md`.
- Manual rotation procedure for `db/app-user` -
  `docs/auxiliary/operations_guide/05-security-model.md` (different
  scope: rotates the password value; this runbook only flips the plugin).
- Post-upgrade follow-up: flip
  `allow_major_version_upgrade` back to `false` at
  `infra/envs/prod/rds.tf:68`. See ADR 0008 -> Post-upgrade follow-ups.

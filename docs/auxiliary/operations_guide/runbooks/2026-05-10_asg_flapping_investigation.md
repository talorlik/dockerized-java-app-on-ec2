# RB-ASG-001 - ASG flap caused by missing S3 read on compose bucket

- Date: 2026-05-10
- Author: agent (Claude)
- Severity: SEV-2 (no healthy targets, full outage on `https://java.talorlik.com`)
- AWS account / region: `260684397593` / `us-east-1`
- Profile used for investigation: `sandbox`
- Scope: `infra/envs/prod` only

## 1. Symptom

`java-app-prod-asg` continuously launched and terminated EC2 instances every
~115s. ALB target group `java-app-prod-tg` reported 0 healthy targets with
`Target.FailedHealthChecks` against every instance until they were terminated.

ASG state during the incident (representative snapshot):

```text
i-0xx (us-east-1a) InService   Healthy
i-0xx (us-east-1b) InService   Unhealthy
i-0xx (us-east-1a) Terminating Unhealthy
i-0xx (us-east-1b) Terminating Unhealthy
```

## 2. Evidence chain

1. `autoscaling describe-scaling-activities` showed every termination with
   cause `"At <T>Z an instance was taken out of service in response to a user
   health-check."`. "User health-check" is the cause string ASG records when
   `SetInstanceHealth` is called via the Autoscaling API (not by ELB).
2. CloudTrail `lookup-events --lookup-attribute EventName=SetInstanceHealth`
   returned events whose principal was the EC2 instance role itself
   (`arn:aws:sts::260684397593:assumed-role/java-app-prod-app-instance/i-...`),
   with `requestParameters.shouldRespectGracePeriod = false`. Conclusion: the
   instance is calling `set-instance-health Unhealthy` on itself, bypassing
   the 600s ASG `health_check_grace_period`.
3. The user-data script (`infra/envs/prod/templates/user_data.sh.tpl`) wires a
   trap (`trap 'self_unhealthy ... ' ERR`) that calls
   `aws autoscaling set-instance-health --health-status Unhealthy
   --no-should-respect-grace-period` on any non-zero exit under
   `set -Eeuo pipefail`. So the symptom = some command in user-data is
   exiting non-zero.
4. CloudWatch log group `/java-app/prod/app` had zero log streams. The CW
   Agent `fetch-config` step in user-data runs AFTER the failing step, so no
   logs are shipped from a failed boot.
5. Two transient instances were `PingStatus=Online` in
   `ssm describe-instance-information`. `ssm send-command` with
   `AWS-RunShellScript` retrieved `/var/log/cloud-init-output.log` from a live
   instance.
6. The retrieved log shows user-data progressing successfully through:
   `apt-get install` (docker-ce, docker-compose-plugin, etc.), AWS CLI v2
   install, CloudWatch Agent install, all 6 SSM `get-parameter` calls (image
   tags, release-id, db endpoint, db name, compose-object), the Secrets
   Manager `db/app-user` fetch, and the `.env` render. Then it fails on:

```text
+ aws s3 cp s3://java-app-prod-config-260684397593/docker-compose.prod.yml /opt/java-app/docker-compose.yml
fatal error: An error occurred (403) when calling the HeadObject operation: Forbidden
+ i=1
+ ((  i >= attempts  ))
+ echo '[user-data] attempt 1 failed for: aws s3 cp ... ; sleeping 5s'
```

   The retry loop runs 5x with 5s sleep (~25s aggregate); after the final
   attempt the function returns 1, the `ERR` trap fires, `self_unhealthy`
   marks the instance Unhealthy with `--no-should-respect-grace-period`, and
   the ASG terminates and replaces it. T+~115s matches.

## 3. Root cause

The EC2 instance role `java-app-prod-app-instance` has no `s3:GetObject`
permission on the configuration bucket
`java-app-prod-config-260684397593`.

- The bucket is created out-of-band by `.github/workflows/infra-apply.yml`
  (lines 127-186); it is NOT a Terraform-managed resource in
  `infra/envs/prod/`.
- The bucket has no resource-based policy
  (`get-bucket-policy` returns `NoSuchBucketPolicy`).
- The role's inline policy in `infra/envs/prod/iam.tf` grants Secrets Manager,
  SSM, KMS Decrypt on the app-secrets CMK, ECR auth, CloudWatch Logs, SES,
  and `autoscaling:SetInstanceHealth`. It grants nothing on S3.
- Therefore `aws s3 cp s3://java-app-prod-config-.../docker-compose.prod.yml`
  fails the implicit HEAD with `403 Forbidden` -> retry exhaustion ->
  user-data ERR trap -> `self_unhealthy` -> ASG terminates.

KMS is not the gating issue; the role already has `kms:Decrypt` on
`aws_kms_key.app_secrets`, and the object's `SSEKMSKeyId` is that same CMK.
KMS would only become the next failure mode after S3 GetObject is granted.

## 4. Fix

Two complementary actions. Apply the hot-fix first to break the loop, then
land the Terraform change to keep the fix across `terraform apply` cycles.

### 4.1 Hot-fix - one-shot put-role-policy

Adds an inline policy directly to the role. Survives Terraform applies as a
sibling policy until the IaC change in 4.2 lands; remove afterwards.

```bash
aws iam put-role-policy \
  --profile sandbox \
  --role-name java-app-prod-app-instance \
  --policy-name java-app-prod-app-config-s3-read-hotfix \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "ReadComposeObject",
        "Effect": "Allow",
        "Action": ["s3:GetObject"],
        "Resource": [
          "arn:aws:s3:::java-app-prod-config-260684397593/docker-compose.prod.yml"
        ]
      }
    ]
  }'
```

The next ASG-launched instance (within ~2 min of the put-role-policy
command) should reach `actuator/health UP`, register Healthy in the ALB
target group, and stop the flap.

After the IaC fix in 4.2 lands and is applied, remove the hot-fix:

```bash
aws iam delete-role-policy \
  --profile sandbox \
  --role-name java-app-prod-app-instance \
  --policy-name java-app-prod-app-config-s3-read-hotfix
```

### 4.2 Terraform IaC fix

Add a new statement to `data "aws_iam_policy_document" "app_inline"` in
`infra/envs/prod/iam.tf`. Diff:

```diff
@@ infra/envs/prod/iam.tf
   # ECR: GetAuthorizationToken is account-scoped (must be *).
   statement {
     sid       = "EcrAuth"
     effect    = "Allow"
     actions   = ["ecr:GetAuthorizationToken"]
     resources = ["*"]
   }

+  # S3 read of the published docker-compose object. The bucket is created
+  # out-of-band by .github/workflows/infra-apply.yml using the deterministic
+  # name java-app-prod-config-${deployment_account_id}; user-data resolves
+  # the s3:// URI from SSM /java-app/prod/compose-object and runs
+  # `aws s3 cp` at boot. Without this grant the HEAD on the object returns
+  # 403, user-data fails, the ERR trap calls self_unhealthy, and the ASG
+  # flaps. The object is encrypted with aws_kms_key.app_secrets (KMS
+  # Decrypt is granted in the DecryptAppCmk statement above).
+  statement {
+    sid    = "ReadComposeObject"
+    effect = "Allow"
+    actions = [
+      "s3:GetObject",
+    ]
+    resources = [
+      "arn:${data.aws_partition.current.partition}:s3:::${var.project}-${var.environment}-config-${var.deployment_account_id}/docker-compose.prod.yml",
+    ]
+  }
+
   # Allow the user-data boot script to mark its own instance Unhealthy if
   # the actuator never returns UP within the boot deadline. ...
   statement {
     sid       = "SelfMarkInstanceUnhealthy"
```

Apply path (manual, gated): `infra-plan.yml` -> review -> `infra-apply.yml`
in the prod environment. Per project hard rules the agent does not run
`terraform apply`.

## 5. Verification steps after applying the hot-fix

```bash
# 1. Watch ASG activities flip to "successful" (no termination cause).
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name java-app-prod-asg-20260509211011706500000023 \
  --profile sandbox --max-items 6

# 2. Watch ALB target health flip to healthy.
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:us-east-1:260684397593:targetgroup/java-app-prod-tg/d87b4ad87a487570 \
  --profile sandbox

# 3. Smoke from the public ALB.
curl -sS https://java.talorlik.com/actuator/health

# 4. Confirm CW logs are now flowing.
aws logs describe-log-streams \
  --log-group-name /java-app/prod/app \
  --order-by LastEventTime --descending --max-items 5 \
  --profile sandbox
```

Healthy state: 2 InService Healthy targets, ALB target group reports
`State=healthy` for both, `actuator/health` returns `{"status":"UP"}`,
CW log streams `<i-...>/user-data`, `<i-...>/cloud-init`, and
`<i-...>/docker` populate.

## 6. Second failure mode - missing `appuser` MySQL account

After the S3 hot-fix landed, instances reached `docker compose up -d` and
the backend container started, but Spring Boot's Flyway initialiser
failed with:

```text
Caused by: java.sql.SQLException: Access denied for user 'appuser'@'10.40.x.y' (using password: YES)
SQL State : 28000  Error Code : 1045
```

Audit per RB-DB-001 step 4 returned an empty `mysql.user` row for
`appuser`: the account was never provisioned. The RDS instance was
recreated under the dev-cycle apply/destroy/re-apply pattern (ADR 0007),
and the previous out-of-band `CREATE USER` step did not run. Flyway runs
AS `appuser`, so it cannot bootstrap its own account.

### 6.1 Hot-fix applied

Idempotent DDL executed via SSM `send-command` against a healthy ASG
instance, using `docker run --rm mysql:8.4` as a transient client:

```sql
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED WITH caching_sha2_password BY '<APP_PW>';
ALTER USER 'appuser'@'%' IDENTIFIED WITH caching_sha2_password BY '<APP_PW>';
GRANT ALL PRIVILEGES ON `javaapp`.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
```

`<APP_PW>` is read from Secrets Manager `/java-app/prod/db/app-user`;
master credentials from the RDS-managed master secret. Verification:

```text
user      host  plugin                  account_locked  password_expired
appuser   %     caching_sha2_password   N                N
GRANT USAGE ON *.* TO `appuser`@`%`
GRANT ALL PRIVILEGES ON `javaapp`.* TO `appuser`@`%`
```

After the bootstrap, Flyway succeeded on the next backend start, the
ALB target group flipped to 2/2 healthy, and `https://java.talorlik.com/actuator/health`
returned `{"status":"UP","groups":["liveness","readiness"]}`.

### 6.2 IaC for survivability across destroy/re-apply

Hot-fix only survives until the RDS instance is replaced. To make the
provisioning durable across dev-cycle re-applies, the following was
added under `infra/envs/prod/`:

- `db_bootstrap.tf` - new file. Creates a dedicated SG, IAM role, Python
  Lambda, and a `terraform_data.db_bootstrap` orchestrator that invokes
  the Lambda whenever:
  - `module.rds.db_instance_resource_id` changes (RDS replacement), or
  - `aws_secretsmanager_secret_version.db_app_user.version_id` changes
    (app-user secret rotation), or
  - the Lambda's `source_code_hash` changes.
- `lambda/db_bootstrap/main.py` - reads the master secret + app-user
  secret, connects to RDS over TLS, runs the same idempotent DDL as in
  6.1. Identifiers are escaped (backtick + single-quote doubling); the
  password is bound via `pymysql` parameter substitution so it never
  appears in any rendered SQL or log line.
- `lambda/db_bootstrap/pymysql/` - vendored PyMySQL 1.1.1
  (44 KB wheel, pure-Python, no native deps). Bundled into the Lambda
  zip by `data "archive_file"`.
- `versions.tf` - added the `hashicorp/archive` provider.
- `rds.tf` - corrected the header comment that previously claimed Flyway
  creates the user.

### 6.3 Manual re-trigger

If anything wedges the Lambda invocation step (e.g. the bootstrap fired
before RDS finished accepting connections), re-run it without a
Terraform apply:

```bash
aws lambda invoke \
  --profile sandbox \
  --region us-east-1 \
  --function-name java-app-prod-db-bootstrap \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{}' \
  /tmp/db_bootstrap_out.json
cat /tmp/db_bootstrap_out.json
```

Expected output: `{"status":"ok","user":"appuser","host":"%","schema":"javaapp","plugin":"caching_sha2_password"}`.

### 6.4 Hot-fix cleanup after IaC apply

After `infra-apply.yml` lands `db_bootstrap.tf` and the IaC s3-read
permission, remove the inline IAM hot-fix:

```bash
aws iam delete-role-policy \
  --profile sandbox \
  --role-name java-app-prod-app-instance \
  --policy-name java-app-prod-app-config-s3-read-hotfix
```

The Terraform-managed `ReadComposeObject` statement (added to
`aws_iam_policy_document.app_inline` in `infra/envs/prod/iam.tf` in this
same change) replaces it. The hot-fix is a sibling inline policy and is
NOT removed by terraform apply automatically.

## 7. Follow-ups (not part of this fix)

- The compose-config bucket is unmanaged by Terraform. Consider promoting
  it (and its KMS-only PutObject policy referenced in app-deploy.yml line
  130 comment, which currently does not exist) into `infra/envs/prod` so
  the bucket policy and IAM read are co-located. This is a structural
  cleanup, separate from the immediate fix.
- The user-data ERR trap calls `set-instance-health Unhealthy
  --no-should-respect-grace-period`, which intentionally bypasses the
  600s grace and means any transient bootstrap error -> immediate
  termination. Acceptable; the design is "fail fast and replace". Pair
  this with a CloudWatch alarm on
  `AWS/AutoScaling GroupTerminatingInstances >= 1 for 3 datapoints in 5
  minutes` so the next flap is detected before manual triage.
- The user-data CloudWatch Agent setup runs after the failing s3 cp step.
  Move the CW Agent config + start to BEFORE the SSM/Secrets/S3 phase so
  future bootstrap failures land in CloudWatch automatically. (Trade-off:
  CW Agent boots faster than the cause of failure in some cases; if the
  failure is in apt-get update itself, this won't help. Still net-positive
  for SSM/S3-class failures.)
- `infra-apply.yml` upload uses default bucket encryption (SSE-S3),
  whereas `app-deploy.yml` upload forces SSE-KMS. Standardize on SSE-KMS
  in both, so the S3 GetObject path always pairs with KMS Decrypt the same
  way.

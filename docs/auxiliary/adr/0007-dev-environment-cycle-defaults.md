# ADR 0007 - Dev-only defaults to support apply / destroy / re-apply cycles

## Status
Accepted

## Context
This stack is currently a development reference implementation. It is not
serving live traffic and is not intended to. The operator workflow is to run
`infra-apply -> infra-destroy -> infra-apply` repeatedly while iterating on
the IaC, the application, and the deployment workflows themselves.

The default AWS resource posture - retained snapshots, deletion protection,
multi-day recovery windows, immutable name reservations - is tuned for
production. Those same defaults block fast destroy/re-apply cycles. They
either fail outright (`InvalidRequestException` on a secret name still in
`PendingDeletion`, `DBInstance has deletion protection enabled`,
`BucketAlreadyOwnedByYou` racing the post-delete settling window) or
require out-of-band CLI surgery between every cycle.

A second pressure: the checkov gate in `ci.yml` runs with `soft_fail: true`
but the audit list is large. We want a green checkov run so that the next
person who reads the SARIF can trust it. Several of the original failures
were either out-of-scope for a single-region reference impl
(cross-region replication), false positives that checkov cannot resolve
(security groups attached via upstream modules), or genuine production
asks that conflict with the dev cycle goal (Secrets Manager rotation
Lambdas, 365-day log retention).

## Decision
Adopt a coherent "dev-cycle defaults" posture across IaC, the supporting
GitHub Actions workflows, and the checkov suppression list. Every decision
below is grounded in the explicit assumption that the env is non-live.
Production-bound deployments must revert these (see "Reverting for
production").

### 1. CloudWatch Logs retention
- `var.log_retention_days = 1` (CloudWatch Logs minimum; sub-day retention
  is not supported by the service).
- Inline `# checkov:skip=CKV_AWS_338` on `aws_cloudwatch_log_group.app` and
  `aws_cloudwatch_log_group.waf`.
- Rationale: CW Logs charges by ingested + stored GB. A dev box that runs
  for hours per cycle does not need >=365-day retention; we accept the
  audit gap and document it.

### 2. CloudWatch / SES / WAF / VPC flow logs
The same `var.log_retention_days` propagates to the VPC flow logs created
by the upstream VPC module and to the new `aws_cloudwatch_log_group.waf`
that satisfies CKV2_AWS_31. All of those will rotate at 1 day in dev.

### 3. Secrets Manager: zero-day recovery window
- `aws_secretsmanager_secret.{db_app_user, admin, jwt, ses}.recovery_window_in_days = 0`.
- Effect: `terraform destroy` removes the secret immediately rather than
  scheduling deletion for 7 days.
- Rationale: the four custom secrets are deterministically reproducible
  from Terraform inputs and `random_password`. A re-apply does not need to
  recover an old secret; it just rebuilds the values. With a non-zero
  recovery window the next apply hits
  `InvalidRequestException: ... already scheduled for deletion` and forces
  the operator to opt into `purge_pending_secrets` on every cycle.
- This explicitly overrides ADR 0005's "Destroy/recreate lifecycle"
  subsection for dev. ADR 0005 remains canonical for live.
- The `purge_pending_secrets.sh` script and the workflow input it backs
  remain in place as defensive no-ops in case state drifts.

### 4. KMS: minimum deletion window
- `aws_kms_key.app_secrets.deletion_window_in_days = 7`.
- `aws_kms_key.tfstate.deletion_window_in_days = 7` (in `infra/bootstrap`,
  which is not normally destroyed).
- Rationale: a re-apply provisions a brand-new key; the orphan key from
  the previous cycle does not need 30 days of recoverability. 7 is the
  KMS minimum.

### 5. RDS: deletion-friendly defaults
| Variable | Old default | New default |
| --- | --- | --- |
| `rds_deletion_protection` | `true` | `false` |
| `rds_skip_final_snapshot` | `false` | `true` |
| `rds_delete_automated_backups` | `false` | `true` |

- Rationale: a final-snapshot orphan blocks the next apply with the same
  identifier prefix; retained automated backups pin the parameter group's
  KMS key and bloat backup quota. Dev cycles do not need either.
- The `infra-destroy.yml` "Prepare RDS for destroy" step still runs and
  remains a defensive layer (it imperatively flips deletion protection
  even when the variable already says false).

### 6. ALB: deletion protection variable-controlled
- New variable `alb_deletion_protection` defaulting to `false`.
- `module.alb.enable_deletion_protection = var.alb_deletion_protection`.
- Rationale: previously the module was hard-wired to `true`, requiring
  the destroy workflow to flip it via `aws elbv2 modify-load-balancer-
  attributes` before `terraform destroy` could touch the ALB. The
  variable lifts that to a normal Terraform input.

### 7. ALB log bucket: force-destroy
- `var.alb_logs_force_destroy = true`.
- Rationale: by the time `terraform destroy` reaches the bucket the ALB
  has stopped writing, but a few last objects always linger. Without
  force-destroy Terraform refuses and the operator manually empties.

### 8. ECR: force_delete
- `aws_ecr_repository.this[*].force_delete = true`.
- Rationale: defensive against partial image-purge failures in
  `infra-destroy.yml`. The image-purge step still runs first; this is the
  fallback so a half-purge does not wedge the destroy.

### 9. Route53: allow_overwrite on cross-account records
- `aws_route53_record.app_alias.allow_overwrite = true`.
- `aws_route53_record.ses_dkim.allow_overwrite = true`.
- Rationale: a partial destroy that fails between RDS teardown and
  Route53 cleanup leaves stale records in the DOMAIN account hosted zone.
  The next apply otherwise fails with
  "Tried to create resource record set ... but it already exists". With
  `allow_overwrite` the apply replaces them transparently.

### 10. SSM parameters: SecureString + CMK
- All seven `aws_ssm_parameter` resources converted from `String` to
  `SecureString` with `key_id = aws_kms_key.app_secrets.key_id`. CI
  shell calls in `app-deploy.yml`, `infra-apply.yml`, `app-destroy.yml`
  pass `--type SecureString --key-id alias/java-app-prod-secrets`
  explicitly so a `put-parameter --overwrite` cannot drift the type.
- User-data SSM reads use `--with-decryption`. The EC2 instance role's
  inline policy already grants `kms:Decrypt` on the app CMK.
- Not strictly a dev-cycle decision, but documented here because it
  changes how operators interact with these parameters (must always
  pass `--with-decryption` when reading).

### 11. S3 hardening on log buckets
- `infra/bootstrap`: added `aws_s3_bucket_versioning.access_logs`,
  `aws_s3_bucket_lifecycle_configuration.access_logs`. Suppressions:
  CKV_AWS_144 (CRR out of scope, single-region), CKV2_AWS_62 (no event
  consumer), CKV_AWS_18 (bucket logs to itself), CKV_AWS_145 (S3 access
  log delivery does not support SSE-KMS CMK).
- `infra/envs/prod`: added `aws_s3_bucket_versioning.alb_logs`,
  `aws_s3_bucket_logging.alb_logs` targeting the bootstrap access_logs
  bucket by deterministic name. Same suppressions where applicable.
  CKV_AWS_145 suppression on the alb_logs SSE config: ALB log delivery
  does not support SSE-KMS CMK on the legacy account-id grant path
  (us-east-1).

### 12. WAF v2 logging
- New `aws_cloudwatch_log_group.waf` (`aws-waf-logs-java-app-prod`,
  KMS-encrypted, 1-day retention) plus
  `aws_wafv2_web_acl_logging_configuration.alb`.
- The app CMK policy condition extended to allow log delivery into both
  `/<project>/<env>/*` and `aws-waf-logs-<project>-<env>*` ARN
  patterns. Required because WAF logging-destination naming forces the
  `aws-waf-logs-` prefix.

### 13. IAM `app_inline` scoping
- CloudWatch Logs writes scoped from `Resource: "*"` to the actual app
  log group ARN plus its `:log-stream:*` child.
- `logs:DescribeLogGroups` split into a separate, account-wide statement
  (no resource-level scoping in IAM).
- Inline `# checkov:skip=` on the policy data source covers the
  remaining wildcards: `logs:DescribeLogGroups`, `ecr:GetAuthorizationToken`,
  `autoscaling:SetInstanceHealth`. None of those have IAM resource-level
  support.

### 14. vpce SG egress tightened
- `aws_security_group.vpce` egress narrowed from `0.0.0.0/0:-1` to
  `var.vpc_cidr:443/tcp`. The SG only attaches to interface VPC
  endpoints, which never reach beyond the VPC.

### 15. checkov suppressions: false positives + out-of-scope
Inline `# checkov:skip=` comments with reasons added for:
- `CKV_TF_1` on the four upstream Terraform modules (`vpc`, `alb`,
  `asg`, `rds`). Pinned via registry tag; commit-hash pinning is
  rejected because it freezes the upstream patch flow.
- `CKV_AWS_260` on `alb_http_redirect`. Public 0.0.0.0/0:80 is the
  intentional 301-redirect path; no traffic is served on 80.
- `CKV2_AWS_5` on `alb`, `app`, `rds` security groups. Each is
  attached to an upstream module via `vpc_security_group_ids` /
  `security_groups`; checkov cannot follow the SG ID through the
  module boundary.
- `CKV2_AWS_57` on the four custom secrets. Rotation Lambdas are out
  of scope for this reference impl. ADR 0005 documents the manual
  rotation strategy; this skip flags the gap.

### 16. Workflow guards under `act`
- Every `actions/upload-artifact` step gated by `if: ${{ !env.ACT }}`.
  GitHub's artifact storage backend is not reachable from `act`'s local
  runner (returns HTTP 401 against `/_apis/pipelines/...`). Real CI
  semantics preserved: still uploads on `success() || failure()` when
  not running under `act`.

### 17. Workflow resilience
- `infra-apply.yml`: compose-bucket creation retries on `OperationAborted`
  for up to ~5 minutes (S3 settles after a recent delete), explicitly
  region-aware so us-east-1 omits `--create-bucket-configuration` while
  every other region adds `LocationConstraint`. `BucketAlreadyOwnedByYou`
  is treated as success; `BucketAlreadyExists` is fatal (name collision
  with a different account).
- `infra-destroy.yml`: terminal step prunes any `*.tflock` /
  `*.tflock.info` objects under `java-app/prod/` in the state bucket.
  Native S3 locking (`use_lockfile = true`) writes those objects, and a
  killed apply leaves them behind, blocking the next acquisition with
  "Error acquiring the state lock". Runs even if earlier destroy steps
  failed.

## Consequences

### Positive
- `infra-apply -> infra-destroy -> infra-apply` runs cleanly with no
  manual intervention between cycles. All known blockers (deletion
  protection, retained snapshots, name reservations, stale lockfiles,
  bucket settling, partial DNS records) are either eliminated or have
  workflow-level recovery.
- `checkov` reports `Failed: 0` on a clean checkout, with every skipped
  check carrying a documented reason.
- Operator burden during iteration is minimized; fewer ad-hoc CLI
  surgery moments between cycles.

### Negative
- The env is unsuitable for production traffic in its current state.
  Anyone reading these defaults must understand that the file
  `infra/envs/prod/variables.tf` does NOT describe a production-safe
  posture despite the directory name.
- A subset of the checkov suppressions is meaningful (CKV_AWS_338 on
  log retention, CKV2_AWS_57 on rotation, CKV_AWS_144 on CRR). Those
  must be re-evaluated when promoting this codebase to live.
- Force-destroy on the ALB log bucket and ECR repos means an accidental
  `terraform destroy` permanently drops content that would normally be
  recoverable. The destroy workflow's confirmation phrase
  (`type DESTROY`) is the only safety net in dev.

## Reverting for production

Before this codebase serves real traffic, every item below must be
flipped or removed.

### Variables (`infra/envs/prod/variables.tf`)

| Variable | Dev default | Production target |
| --- | --- | --- |
| `log_retention_days` | `1` | `>= 365` (compliance-driven) |
| `rds_deletion_protection` | `false` | `true` |
| `rds_skip_final_snapshot` | `true` | `false` |
| `rds_delete_automated_backups` | `false` | `false` (already) |
| `alb_logs_force_destroy` | `true` | `false` |
| `alb_deletion_protection` | `false` | `true` |

### Resources

- `aws_secretsmanager_secret.*.recovery_window_in_days`: `0` -> `7`
  (the value documented in ADR 0005).
- `aws_kms_key.app_secrets.deletion_window_in_days`: `7` -> `30`.
- `aws_kms_key.tfstate.deletion_window_in_days` in `infra/bootstrap`:
  `7` -> `30`.
- `aws_ecr_repository.this[*].force_delete`: `true` -> `false`.

### Suppressions to remove or replace

- `CKV_AWS_338` skips on `aws_cloudwatch_log_group.app` and
  `aws_cloudwatch_log_group.waf` (the bumped retention will then pass).
- `CKV2_AWS_57` skips on the four secrets, replaced with actual
  `aws_secretsmanager_secret_rotation` blocks pointing at a rotation
  Lambda. ADR 0005 already lays out which secrets are rotatable how.
- `CKV_AWS_144` skips on the three S3 buckets, replaced with
  `aws_s3_bucket_replication_configuration` if cross-region replication
  is policy-required.
- `CKV2_AWS_5` skips on the three SGs may stay; checkov still cannot
  follow them through the module boundary.
- `CKV_TF_1` skips on the four upstream modules - decide based on the
  org's supply-chain stance.

### Workflows
- The `if: ${{ !env.ACT }}` guards on artifact uploads can stay; they
  are no-ops on real CI.
- The compose-bucket retry loop and lockfile prune both stay.

## Relationship to other ADRs
- **ADR 0005 (Secret rotation strategy)**: this ADR explicitly
  overrides 0005's "Destroy/recreate lifecycle" subsection for dev
  environments. 0005 remains canonical for live. The override is
  documented inline in `infra/envs/prod/secrets.tf`.
- **ADR 0003 (WAF)**: this ADR adds the WAF logging configuration that
  0003 left implicit. WAF logs flow into `aws-waf-logs-java-app-prod`
  with `var.log_retention_days` retention.
- **ADR 0006 (Two-account provider model)**: cross-account Route53
  records now carry `allow_overwrite = true`. The DOMAIN-account role
  trust posture is unchanged.

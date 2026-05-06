# Dockerized Java App on EC2

Production-shaped reference deployment of a Dockerized Spring Boot app on
EC2 ASG behind a public ALB, fronted by Nginx, persisted in RDS MySQL, with
secrets in Secrets Manager, releases tracked in SSM Parameter Store, and
operator-triggered CI/CD via GitHub Actions OIDC.

Public endpoint: `https://java.talorlik.com` (HTTP/80 is redirected to HTTPS/443).

## Topology

```text
Internet
  |
  | HTTPS :443  (HTTP :80 -> 301 -> HTTPS :443)
  v
Route53 (DOMAIN account) - A alias  java.talorlik.com
  |
  v
ALB (DEPLOYMENT account, public subnets, ACM cert)
  |
  | HTTP :8080
  v
ASG of EC2 (private subnets, Ubuntu LTS)
  |
  | docker compose up -d
  +-- frontend  Nginx, host port 8080:80, /api/* -> backend
  +-- backend   Spring Boot 3.5, Java 21, JWT auth
  +-- CloudWatch Agent
  |
  | TCP 3306
  v
RDS MySQL (private DB subnets, Multi-AZ, encrypted)
```text

## Repository layout

```text
.
├── infra/
│   ├── bootstrap/         # one-time S3+KMS for remote state
│   └── envs/prod/         # main TF env: VPC, ALB, ASG, RDS, ECR, IAM, WAF, Route53, observability
├── app/
│   ├── backend/           # Spring Boot 3.5 / Java 21 / Maven
│   ├── frontend/          # Vanilla JS + Nginx
│   └── docker/            # docker-compose.local.yml + docker-compose.prod.yml + env.template
├── tests/e2e/             # Playwright suite
├── .github/workflows/     # ci.yml, infra-plan.yml, infra-apply.yml,
│                          # infra-destroy.yml, app-deploy.yml, app-destroy.yml
└── docs/                  # auxiliary/operations_guide + ADRs + planning docs
```

## Decisions

Locked decisions in this delivery:

- Frontend: plain HTML/CSS/vanilla JS.
- Auth: JWT bearer in `Authorization` header (stateless, SPA-friendly, no CSRF surface).
- WAF: enabled (`aws_wafv2_web_acl` attached to ALB; managed Common +
  KnownBadInputs + SQLi + 2000 req / 5 min IP rate limit).
- CSV export: included (`/api/admin/users.csv`).
- Spring Boot: `3.5.x` (Spring Boot 3.5.0 release line).
- Java: 21 LTS.
- Ubuntu: dynamic SSM lookup (`var.ubuntu_lts_codename`, default `noble` =
  24.04 LTS) (unverified - check Canonical's SSM listing).
- Region: `us-east-1`.

ADRs in `docs/auxiliary/adr/`. Detailed setup, ops, and security in
`docs/auxiliary/operations_guide`.

---

## Deploy from scratch

Time budget on a clean account: roughly 30-45 minutes of wall clock,
most of which is RDS Multi-AZ provisioning and the first ASG instance
refresh. Tooling versions are listed in
`docs/auxiliary/operations_guide/00-prerequisites.md`.

### 0. One-time prerequisites (manual, outside this repo)

1. Pick a **DEPLOYMENT** AWS account (where ALB, EC2, ASG, RDS, ECR,
   KMS, Secrets Manager, ACM live) and a **DOMAIN** AWS account (where
   the public hosted zone for `talorlik.com` lives). They may be the
   same account.
2. In DEPLOYMENT account, create or identify the GitHub OIDC role used
   by Actions (referred to below as `DEPLOYMENT_ROLE_ARN`). Trust
   `repo:<owner>/<repo>:ref:refs/heads/main` (and any other refs you
   want to permit).
3. In DOMAIN account, create `route53-dns-manager-role` with:
   - trust policy allowing `sts:AssumeRole` from the DEPLOYMENT account
     `github-role`,
   - permissions limited to `route53:ChangeResourceRecordSets`,
     `GetChange`, `ListResourceRecordSets` on the
     `talorlik.com` hosted zone, plus `ListHostedZones`/`GetHostedZone`.
   Full JSON examples in
   `docs/auxiliary/operations_guide/02-domain-account-dns.md`.
4. In DEPLOYMENT account (`us-east-1`), issue an ACM certificate for
   `java.talorlik.com`. Validate via DNS records placed in the DOMAIN
   account zone. Copy the certificate ARN.
5. In GitHub:
   - **Variables**: `AWS_REGION`, `DEPLOYMENT_ACCOUNT_ID`,
     `DOMAIN_ACCOUNT_ID`, `HOSTED_ZONE_ID`.
   - **Secrets**: `ACM_CERTIFICATE_ARN`, `DEPLOYMENT_ROLE_ARN`,
     `DOMAIN_ROUTE53_ROLE_ARN`.
   - **Environment** named `prod`. All apply/destroy workflows pin to
     it; add a required-reviewer protection rule if you want a manual
     approval gate.

### 1. Bootstrap remote Terraform state (one-shot, local)

Use admin-level credentials in DEPLOYMENT account for this run only.

```bash
cd infra/bootstrap
export AWS_REGION=us-east-1

terraform init
terraform apply \
  -var aws_region=us-east-1 \
  -var state_bucket_name="java-app-tfstate-<DEPLOYMENT_ACCOUNT_ID>-us-east-1"

terraform output backend_block_example
```

Copy the printed block into `infra/envs/prod/backend.tf`, replacing
the existing placeholder values, and commit.

The bootstrap stack uses local state by design (it cannot point at a
backend that does not yet exist). Treat the local `.terraform/` dir as
disposable - everything needed to rehydrate the env lives in S3 plus
this repo.

### 2. (Optional) Inspect a plan before applying

```bash
gh workflow run infra-plan.yml
gh run watch
```

`infra-plan.yml` uploads `tfplan` and `plan.txt` as artifacts and dumps
a truncated plan into the job summary.

### 3. Apply infrastructure

```bash
gh workflow run infra-apply.yml
gh run watch
```

This workflow:

- assumes `DEPLOYMENT_ROLE_ARN` via OIDC,
- `terraform init` against the bootstrap state bucket,
- `terraform apply` with TF_VARs pulled from repo vars + secrets,
- creates (if absent) `s3://java-app-prod-config-<account>/`, uploads
  `app/docker/docker-compose.prod.yml` to it, and writes the
  `s3://...` URI into the SSM parameter
  `/java-app/prod/compose-object`.

After it finishes, ECR repos exist but contain no images, and the
ASG's launch template points at the `bootstrap` image tag. Instances
will boot but will not pull a real app yet.

### 4. Build images and roll the ASG

```bash
gh workflow run app-deploy.yml
gh run watch
```

This workflow:

- runs `ci.yml` as a gate (backend `mvn verify` with Testcontainers
  MySQL, frontend asset sanity, docker compose smoke + Playwright
  E2E, terraform fmt/validate/tflint/checkov),
- builds `backend` and `frontend` images tagged `sha-<12char>`,
- pushes them to ECR,
- writes the new tags into SSM
  (`/java-app/prod/{backend-image-tag,frontend-image-tag,release-id}`),
- starts an ASG instance refresh (`MinHealthyPercentage=100`,
  `MaxHealthyPercentage=200`, `InstanceWarmup=180`,
  `AutoRollback=true`) and polls until it reports `Successful`,
- runs a final smoke check against
  `https://java.talorlik.com/actuator/health`.

To pin a specific image tag instead of the commit SHA:

```bash
gh workflow run app-deploy.yml -f image_tag=sha-1234567890ab
```

### 5. First-time admin login

```bash
aws secretsmanager get-secret-value \
  --secret-id /java-app/prod/admin \
  --query SecretString --output text | jq .
```

Use `username` (`admin@talorlik.com`) and `password` to log in at
`https://java.talorlik.com/login`. The seed is idempotent; rotating
the secret value and triggering an instance refresh re-applies it
without overwriting existing rows.

### 6. (Optional) SES production access

The first apply registers the SES sender domain identity and writes
DKIM CNAMEs into the DOMAIN zone, but a brand-new account is in the
SES sandbox. Verify a recipient address (or request production access
in the SES console) before relying on outbound mail.

---

## Destroy everything

Reverse order. Both workflows require typing `DESTROY` (uppercase) as
the `confirm` input.

### 1. Tear down the application layer

```bash
gh workflow run app-destroy.yml -f confirm=DESTROY
gh run watch
```

Scales the ASG to 0, drains instances, resets the three SSM release
pointers to `bootstrap`, deletes the published
`docker-compose.prod.yml` from the config bucket, and empties both ECR
repos.

This is optional - `infra-destroy.yml` re-runs the same cleanup by
default - but useful if you only want to halt the running app without
removing the underlying infra.

### 2. Tear down the prod infrastructure

```bash
gh workflow run infra-destroy.yml -f confirm=DESTROY -f run_app_cleanup=true
gh run watch
```

Steps performed by the workflow:

- repeats app cleanup (skip with `run_app_cleanup=false`),
- disables ALB access logs and deletion protection,
- empties the ALB-logs bucket and the config bucket (versioned
  objects + delete markers),
- removes the EC2 Auto Scaling and ELB service-linked roles from
  Terraform state (account-wide; AWS recreates them on next use),
- disables RDS deletion protection imperatively, waits for
  `available`, and purges any orphaned automated backups,
- runs `terraform destroy` with these overrides:
  `TF_VAR_rds_deletion_protection=false`,
  `TF_VAR_rds_skip_final_snapshot=true`,
  `TF_VAR_rds_delete_automated_backups=true`,
  `TF_VAR_alb_logs_force_destroy=true`.

Does **not** touch the bootstrap state stack. Re-running
`infra-apply.yml` will rebuild prod over the same state bucket /
KMS CMK.

### 3. (Optional) Remove the bootstrap state stack

Only do this if you are decommissioning the project entirely. Once the
state bucket is gone you cannot recover prior plans/state.

```bash
# Local credentials with admin in DEPLOYMENT account.
cd infra/bootstrap

# Empty the state bucket (it has versioning + a DenyInsecureTransport
# policy; native `aws s3 rm --recursive` will not always recurse over
# noncurrent versions, hence list+delete).
B="java-app-tfstate-<DEPLOYMENT_ACCOUNT_ID>-us-east-1"
while :; do
  PAYLOAD=$(aws s3api list-object-versions --bucket "$B" --max-items 900 --output json \
    | jq -c '{Objects: [((.Versions // [])[]),
                        ((.DeleteMarkers // [])[])
                        | {Key, VersionId}],
             Quiet: true}')
  COUNT=$(printf '%s' "$PAYLOAD" | jq '.Objects | length')
  [ "$COUNT" -eq 0 ] && break
  aws s3api delete-objects --bucket "$B" --delete "$PAYLOAD"
done

# If access logging is on, do the same for "${B}-access-logs".

terraform destroy \
  -var aws_region=us-east-1 \
  -var state_bucket_name="$B"
```

The KMS CMK enters a 30-day deletion window; it is not destroyed
immediately.

### 4. (Optional) DOMAIN-account cleanup

The Terraform destroy removes the `java.talorlik.com` A alias and the
SES DKIM CNAMEs. The hosted zone, ACM certificate, and
`route53-dns-manager-role` are operator-owned; remove them manually
if no longer needed.

---

## Quality gates

`ci.yml` enforces, on every `app-deploy` run and on demand:

- backend `mvn verify` (Surefire unit + Failsafe integration with
  Testcontainers MySQL),
- Docker build of backend + frontend,
- `docker compose up` smoke test against the local compose file,
- Playwright E2E (smoke spec, headless Chromium),
- Terraform fmt, validate, tflint, checkov (soft-fail).

`app-deploy.yml` calls `ci.yml` via `workflow_call` as a gate before
building and pushing images.

## Operations cheatsheet

- App + Docker + cloud-init logs: CloudWatch log group
  `/java-app/prod/app`.
- Dashboard: `java-app-prod-main` in CloudWatch.
- Alarms route to SNS topic `java-app-prod-alarms` (subscribe an email
  by setting `var.alarm_email` and re-applying).
- ALB access logs: S3 bucket `java-app-prod-alb-logs-<account>`.
- Roll a release manually: `gh workflow run app-deploy.yml`.
- Restart on a single node:

  ```bash
  aws ssm start-session --target <i-...>
  sudo -i
  cd /opt/java-app
  docker compose --env-file /opt/java-app/.env restart
  ```

  The `--env-file` is mandatory; the prod compose file interpolates
  `BACKEND_IMAGE` / `FRONTEND_IMAGE` from `/opt/java-app/.env`.

Full operations notes in
`docs/auxiliary/operations_guide/04-operations.md`. Security model in
`docs/auxiliary/operations_guide/05-security-model.md`.

## License

See `LICENSE`.

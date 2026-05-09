# CLAUDE.md

Operational guide for Claude (and other AI agents) working in this repository.
Read this file before any non-trivial action. The canonical product/architecture
spec is `docs/auxiliary/planning/PROJECT_OVERVIEW.md`; this file is the
agent-facing summary plus repo-specific rules.

## 1. Project identity

Reference implementation for deploying a Dockerized Java app to AWS EC2 behind
an ALB.

> **Dev-only env.** This stack is currently configured for fast
> apply/destroy/re-apply iteration, not production. Several "production-safe"
> defaults (RDS deletion protection, Secrets Manager recovery windows, KMS
> deletion windows, ECR force_delete, ALB deletion protection, log retention)
> are flipped. ADR 0007 is the canonical reference for every override and the
> production-revert checklist. Do not promote this codebase to live without
> walking that checklist.

- Backend: Spring Boot 3.5.0 (Java 21, Maven), JPA + Flyway against RDS MySQL,
  JWT auth (`jjwt` 0.12.6), Bucket4j rate limiting (8.10.1), AWS SDK v2
  (2.28.16) for Secrets Manager and SES.
- Frontend: vanilla HTML/CSS/JS served by Nginx; Nginx proxies `/api/` to the
  backend container.
- Runtime: EC2 Auto Scaling Group on private subnets, Docker Compose pulls
  images from ECR, ALB on `443` (with `80 -> 443` redirect) forwards to
  instance port `8080` (frontend Nginx, published as `8080:80`).
- Data: Amazon RDS MySQL in private DB subnets. EC2 must remain stateless.
- IaC: Terraform with S3 remote state and native S3 locking
  (`use_lockfile = true`). DynamoDB locking is not used.
- CI/CD: GitHub Actions, OIDC into a `github-role` in the DEPLOYMENT account,
  cross-account `assume_role` into the DOMAIN account for Route53.
- DNS/TLS: `java.talorlik.com` Route53 A alias to ALB; ACM certificate in the
  DEPLOYMENT account.

## 2. Repository layout

```text
.
|- app/
|  |- backend/                 Spring Boot service (Java 21, Maven)
|  |  |- pom.xml
|  |  |- Dockerfile
|  |  `- src/{main,test}/...
|  |- frontend/                Static Nginx site
|  |  |- Dockerfile
|  |  |- nginx.conf
|  |  `- src/{index.html,css,js}
|  `- docker/
|     |- docker-compose.local.yml   Local dev: includes mysql container
|     `- docker-compose.prod.yml    Prod runtime: backend + frontend only
|- infra/
|  |- bootstrap/               One-time S3 state bucket (run once per account)
|  `- envs/prod/               All prod AWS resources
|     |- backend.tf, providers.tf, versions.tf, locals.tf, main.tf
|     |- network.tf, security.tf, secrets.tf, ecr.tf
|     |- alb.tf, asg.tf, iam.tf, route53.tf, waf.tf, ses.tf
|     |- observability.tf, outputs.tf
|     `- terraform.tfvars.example
|- tests/e2e/                  Playwright suite (TS)
|- docs/
|  |- auxiliary/operations_guide/00-prerequisites.md ... 05-security-model.md   Operator handoff docs
|  |- auxiliary/adr/0001..0006-*.md   Architecture decision records
|  `- auxiliary/planning/      Source-of-truth product/tech specs
|- .github/workflows/
|  |- ci.yml                   workflow_dispatch + workflow_call quality gate
|  |- infra-plan.yml           workflow_dispatch terraform plan for infra/envs/prod
|  |- infra-apply.yml          workflow_dispatch terraform apply (prod environment gate)
|  |- infra-destroy.yml        workflow_dispatch teardown (typed `DESTROY` confirm)
|  |- app-deploy.yml           workflow_dispatch build, push to ECR, ASG instance refresh
|  `- app-destroy.yml          workflow_dispatch app-layer teardown (typed `DESTROY` confirm)
|- .editorconfig, .gitattributes, .vscode/, LICENSE
```

Generated/vendored content the agent must not edit:

- `infra/envs/prod/.terraform/**` (Terraform module cache, modules are vendored
  by `terraform init`).
- `app/backend/target/**` (Maven build output).
- `node_modules/` under `tests/e2e/`.

## 3. Tech stack and pinned versions

| Layer        | Tool/version                                                    |
|--------------|-----------------------------------------------------------------|
| Language     | Java 21 (Temurin in CI), Node for Playwright only               |
| Framework    | Spring Boot 3.5.0 parent (see pom.xml `parent.version`)         |
| Build        | Maven Wrapper `./mvnw` (committed at `app/backend/mvnw`, version pinned via `.mvn/wrapper/maven-wrapper.properties`); system `mvn` works locally |
| DB           | MySQL 8.4 LTS (RDS in prod, Testcontainers in CI, container locally) |
| Migrations   | Flyway, files at `app/backend/src/main/resources/db/migration/` |
| Auth         | Spring Security + jjwt 0.12.6                                    |
| Rate limit   | Bucket4j 8.10.1                                                  |
| AWS SDK      | software.amazon.awssdk 2.28.16 (Secrets Manager, SES)            |
| Tests        | JUnit 5 + Mockito (unit), Failsafe + Testcontainers 1.20.4 (IT) |
| Web tests    | Playwright (TypeScript) under `tests/e2e/`                       |
| IaC          | Terraform with S3 backend, `use_lockfile = true`                 |
| Modules      | `terraform-aws-modules/{vpc,alb,rds,autoscaling}/aws` (pinned)   |
| Containers   | Docker Engine + Compose v2 (`docker compose`, not `docker-compose`)|

PROJECT_OVERVIEW.md mentions Spring Boot `3.5.14` and `4.0.6` as upstream
options; the pom is on `3.5.0`. Do not bump without explicit instruction.
(unverified - check docs for current 3.5.x patch line.)

## 4. Build, test, run commands

Run from repo root unless noted. Paths are host paths.

Backend:

```bash
# Canonical CI path uses the wrapper. ci.yml chmods +x ./mvnw before invoke
# to defend against archive imports / Windows clones with core.fileMode=false.
cd app/backend && chmod +x ./mvnw

# Compile + unit + integration tests (Failsafe, Testcontainers MySQL).
cd app/backend && ./mvnw -B -ntp verify

# Unit tests only.
cd app/backend && ./mvnw -B -ntp test

# Package the jar without running tests (rare; CI always runs verify).
cd app/backend && ./mvnw -B -ntp -DskipTests package
```

System `mvn` works locally as a fallback; CI always uses `./mvnw`.

Frontend: vanilla JS, no build step. CI only verifies that
`app/frontend/src/index.html` and `app/frontend/nginx.conf` exist.

Local stack (with MySQL container):

```bash
cd app/docker
docker compose -f docker-compose.local.yml up --build
# Tear down + remove volumes:
docker compose -f docker-compose.local.yml down -v
```

Prod-shape stack (no DB container; expects RDS env):

```bash
cd app/docker
docker compose -f docker-compose.prod.yml config   # validate only
```

E2E:

```bash
cd tests/e2e
npm ci
npx playwright install --with-deps
npx playwright test
```

Terraform (prod env):

```bash
cd infra/envs/prod
terraform init
terraform fmt -recursive -check
terraform validate
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars   # gated; do not run from agent
```

Static analysis (run before opening a PR that touches `infra/**`):

```bash
tflint --init && tflint --recursive
checkov -d infra/envs/prod
tfsec  infra/envs/prod
```

Sandbox note: `terraform`, `tflint`, `checkov`, `tfsec`, and `mvn` cannot be
installed inside Claude's sandbox because the egress proxy blocks the relevant
origins. Invoke them through the `host-tools` MCP server, which exposes the
binaries already installed on the user's Mac (see section 9).

## 5. Local development workflow

1. Copy `app/docker/env.template` (referenced by PROJECT_OVERVIEW) to
   `app/docker/.env` and fill in values. The `.env` file is not committed.
2. `docker compose -f app/docker/docker-compose.local.yml up --build`.
3. Backend exposes `:8080`. Frontend Nginx exposes `:8080` on the host with
   `/api/` proxied to the backend container.
4. Flyway runs on backend startup. Migrations live in
   `app/backend/src/main/resources/db/migration/V{n}__{name}.sql`.
5. Admin seed: `AdminSeeder` reads `/java-app/prod/admin` from Secrets Manager
   in prod; for local, supply equivalent env vars (see `application.yml` and
   `AppProperties`).

## 6. Deployment model

- Trigger: `workflow_dispatch` only (optional `image_tag` input; defaults to
  `sha-${GITHUB_SHA::12}`); calls `ci.yml` via `workflow_call` as a quality
  gate. There is no `push:` or `pull_request:` trigger.
- Build: backend and frontend Docker images, tagged `${GITHUB_SHA}`. Never use
  `latest` for runtime.
- Push: ECR repos provisioned in `infra/envs/prod/ecr.tf`.
- Release pointer: SSM Parameter Store keys updated by the workflow:
  - `/java-app/prod/backend-image-tag`
  - `/java-app/prod/frontend-image-tag`
  - `/java-app/prod/release-id`
- Rollout: ASG Instance Refresh with `min_healthy_percentage = 100`,
  `max_healthy_percentage = 200` (launch-before-terminate).
- Post-deploy: smoke against `https://java.talorlik.com/actuator/health`
  (port 443 default; matches `app-deploy.yml:150`).
- Rollback: re-run `app-deploy.yml` with the previous SHA as the dispatch
  input; do not delete ECR images.

## 7. AWS account topology and required GitHub repo vars

Two accounts:

- DEPLOYMENT: VPC, ALB, EC2/ASG, RDS, ECR, Secrets Manager, ACM cert, SES.
- DOMAIN: Route53 hosted zone for `talorlik.com`. Terraform reaches it via a
  second `aws` provider alias that assumes a DNS-write role.

Required GitHub repository configuration (set in repo settings, never
committed). The split mirrors `.github/{vars,secrets}.local` for `act`
parity; workflows reference these as `${{ vars.* }}` and `${{ secrets.* }}`.

Variables (`vars.*` in workflows):

```
AWS_REGION
DEPLOYMENT_ACCOUNT_ID
DOMAIN_ACCOUNT_ID
HOSTED_ZONE_ID
```

Secrets (`secrets.*` in workflows):

```
DEPLOYMENT_ROLE_ARN
DOMAIN_ROUTE53_ROLE_ARN
ACM_CERTIFICATE_ARN
```

OIDC trust: `token.actions.githubusercontent.com` provider, audience
`sts.amazonaws.com`. The DEPLOYMENT `github-role` trusts this OIDC subject;
the DOMAIN `route53-dns-manager-role` trusts the DEPLOYMENT `github-role` for
chained assume-role.

## 8. Conventions

- Editor: `.editorconfig` enforces LF, UTF-8, 2-space indent (4 for `.java`
  and `.sql`, tabs in `Makefile`), final newline, trim trailing whitespace
  except in `.md`.
- File names: snake_case for new files except where a tool dictates otherwise
  (Java classes PascalCase, Terraform `.tf` files lowercase by purpose,
  Flyway migrations `V{int}__{snake_case}.sql`).
- ADRs: `docs/auxiliary/adr/NNNN-kebab-title.md`, monotonically numbered.
- Migrations: never edit an applied `V*__*.sql`; add a new `V{n+1}__*.sql`.
- Secrets: never inline. Read from Secrets Manager in app code; reference by
  ARN/path in Terraform. No secrets in user-data, in `tfvars`, or in
  `application.yml`.
- Logs: never log password, JWT, verification code, or full request bodies.
- Triggers: every workflow uses `workflow_dispatch:` (manual dispatch only);
  `ci.yml` additionally exposes `workflow_call:` so `app-deploy.yml` can use
  it as a reusable quality gate. No workflow has a `push:` or
  `pull_request:` trigger. The docs-drift script
  `.github/scripts/docs_drift_check.sh` actively forbids legacy phrases like
  "merge to main" and "PR plan for infra/**".

## 9. Host tooling MCP

Binaries that cannot be installed inside the sandbox (because the egress
proxy blocks Hashicorp, Maven Central, etc.) are reached through the
`host-tools` MCP server. The server invokes binaries already installed on
the user's Mac and returns stdout/stderr/exit-code. Relevant tool names
(prefixed `mcp__host-tools__` when called as functions):

- `terraform_fmt`, `terraform_init`, `terraform_validate`, `terraform_plan`,
  `terraform_show`, `terraform_version`
- `terragrunt_run`
- `tflint_cli`, `tfsec_cli`, `checkov_cli`
- `aws_cli`, `gh_cli`, `az_cli`, `gcloud_cli`, `gsutil_cli`, `bq_cli`
- `docker_cli`, `docker_compose`
- `kubectl_cli`, `kubectl_apply_dry`, `kustomize_cli`, `helm_cli`,
  `helmfile_cli`
- `ansible_cli`, `ansible_playbook`
- `argo_cli`, `argocd_cli`
- `sam_cli`, `serverless_cli`, `eksctl_cli`
- `orb_info`, `orb_start`, `orb_status`, `orb_stop`
- `bin_list`, `bin_run`, `which`

Constraints:

- Never run `terraform apply` or `terraform destroy` from agent context, even
  through this MCP. Produce a plan and let the user run apply via the
  GitHub workflow or locally. (Same rule as section 10.)
- `mvn` and `gradle` are not currently exposed as dedicated tools in
  `host-tools`. For Maven verify (`mvn -B -ntp verify`) the agent should
  ask the user to run it locally, or use `bin_run` if the user has whitelisted
  `mvn` there. (unverified - check with `bin_list`.)
- The MCP-side allow-list governs which host binaries may be invoked. The
  agent does not edit it.

## 10. Hard rules for the agent

- Never commit or print secrets. If a value looks like a credential, redact.
- Never deploy or tag `latest`. Always `${GITHUB_SHA}` or an explicit semver.
- Never open SSH (TCP 22) ingress on EC2. Use SSM Session Manager.
- Never disable IMDSv2 enforcement.
- Never make RDS publicly accessible. App SG is the only allowed source.
- Never edit files under `infra/envs/prod/.terraform/**` (vendored module
  cache; regenerated by `terraform init`).
- Never overwrite an applied Flyway migration. Add a new one.
- Never run `terraform apply` or `terraform destroy` from agent context.
  Produce a plan, surface it, and let the user run apply via the GitHub
  workflow or locally.
- Never delete files. If removal is needed, propose a diff and wait for
  confirmation.
- Before any multi-step task, output a numbered plan and wait for approval
  (per the user's global task-execution protocol).

## 11. Pointers (read these before deeper work)

- `docs/auxiliary/planning/PROJECT_OVERVIEW.md` - canonical architecture and
  phased build plan (phases 0-20).
- `docs/auxiliary/planning/PRODUCT_REQUIREMENTS_DOCUMENT.md` - product scope.
- `docs/auxiliary/planning/TECHNICAL_REQUIREMENTS_REFERENCE.md` - tech
  requirements detail.
- `docs/auxiliary/planning/ENGINEERING_EXECUTION_BACKLOG.md` - work breakdown.
- `docs/auxiliary/operations_guide/00-prerequisites.md` through
  `docs/auxiliary/operations_guide/05-security-model.md` - operator handoff
  docs.
- `docs/auxiliary/adr/0001..0008-*.md` - decisions: frontend stack, auth model,
  WAF, Ubuntu resolution, secret rotation, provider/account model, dev-only
  apply/destroy/re-apply defaults, MySQL 8.4 LTS upgrade. ADR 0007 is the
  canonical reference for every dev-cycle override and the production-revert
  checklist; ADR 0008 covers the 8.0 -> 8.4 engine bump.

## 12. Known gaps and unverifieds

- Spring Boot version: `app/backend/pom.xml:11` is on `3.5.0`. Current 3.5.x
  patch line is `3.5.13` (March 2026) and `3.5` is the final 3.x minor; OSS
  support ends 2026-06-30. Spring Boot 4.0 has been GA since November 2025
  (`4.0.6`, April 2026) and is the upstream-recommended target for new work.
  The `3.5.0` pin is intentional - do not bump without explicit instruction
  (Section 10 hard rule). Two valid bump paths when approval comes:
  (a) `3.5.0` -> `3.5.13` in-line patch on the same minor (lowest blast
  radius); (b) `3.5.x` -> `4.0.x` migration onto Spring Framework 7.0
  (larger change, requires audit of jjwt 0.12.6, AWS SDK v2 2.28.16,
  Bucket4j 8.10.1, Spring Security upgrade notes).
- Ubuntu AMI: `infra/envs/prod/variables.tf:114-121` defines
  `var.ubuntu_lts_codename` with default `noble` (24.04 LTS).
  `infra/envs/prod/asg.tf:10-11` resolves the AMI ID at apply time from
  Canonical's SSM at
  `/aws/service/canonical/ubuntu/server/${codename}/stable/current/amd64/hvm/ebs-gp3/ami-id`.
  Switch via the variable (e.g. `resolute` for 26.04 LTS) once the new
  codename is GA in the target region. (unverified - check Canonical's
  release calendar for 26.04 LTS GA timing.)
- Port mapping (verified 2026-05-09 against `infra/envs/prod/locals.tf:25-27`
  and `app/docker/docker-compose.prod.yml`): ALB listener `443` (HTTPS) and
  `80` (HTTP -> 443 redirect), target group port `8080`. Frontend container
  publishes `8080:80` (Nginx port 80 inside the container, port 8080 on the
  EC2 host). Backend container `expose`s 8080 internally only; Nginx proxies
  `/api/` to the backend's 8080.
- Post-upgrade follow-up tracked from ADR 0008. Current state (verified
  2026-05-09 against `infra/envs/prod/rds.tf:68`):
  `allow_major_version_upgrade = true`, `apply_immediately = true`
  (`rds.tf:73`). Action when the MySQL 8.0 -> 8.4 apply has landed and
  the post-upgrade smoke passes: flip `allow_major_version_upgrade` back
  to `false` at `rds.tf:68`; optionally also remove
  `apply_immediately = true` for a production-safe default. Pre-flight
  before the upgrade itself: runbook
  `docs/auxiliary/operations_guide/runbooks/2026-05-08_appuser_auth_plugin_conversion.md`
  (RB-DB-001) - convert `appuser` from `mysql_native_password` to
  `caching_sha2_password`, since 8.4 no longer auto-loads the legacy
  plugin.

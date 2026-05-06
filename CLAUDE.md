# CLAUDE.md

Operational guide for Claude (and other AI agents) working in this repository.
Read this file before any non-trivial action. The canonical product/architecture
spec is `docs/auxiliary/planning/PROJECT_OVERVIEW.md`; this file is the
agent-facing summary plus repo-specific rules.

## 1. Project identity

Java signup platform deployed to AWS EC2 behind an ALB.

- Backend: Spring Boot 3.5.0 (Java 21, Maven), JPA + Flyway against RDS MySQL,
  JWT auth (`jjwt` 0.12.6), Bucket4j rate limiting (8.10.1), AWS SDK v2
  (2.28.16) for Secrets Manager and SES.
- Frontend: vanilla HTML/CSS/JS served by Nginx; Nginx proxies `/api/` to the
  backend container.
- Runtime: EC2 Auto Scaling Group on private subnets, Docker Compose pulls
  images from ECR, ALB on `8443` forwards to instance port `8080`.
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
|  |- ci.yml                   PR + workflow_call quality gate
|  |- infra-plan.yml           PR plan for infra/**
|  |- infra-apply.yml          Apply on main / dispatch
|  |- infra-destroy.yml        Manual teardown
|  |- app-deploy.yml           Build, push to ECR, ASG instance refresh
|  `- app-destroy.yml
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
| Build        | Maven (no wrapper present; use system `mvn`)                    |
| DB           | MySQL 8.x (RDS in prod, Testcontainers in CI, container locally)|
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
# Compile + unit + integration tests (Failsafe, Testcontainers MySQL).
cd app/backend && mvn -B -ntp verify

# Unit tests only.
cd app/backend && mvn -B -ntp test

# Package the jar without running tests (rare; CI always runs verify).
cd app/backend && mvn -B -ntp -DskipTests package
```

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

- Trigger: merge to `main` (or manual dispatch with explicit image tag) runs
  `app-deploy.yml`, which `workflow_call`s `ci.yml` as a gate.
- Build: backend and frontend Docker images, tagged `${GITHUB_SHA}`. Never use
  `latest` for runtime.
- Push: ECR repos provisioned in `infra/envs/prod/ecr.tf`.
- Release pointer: SSM Parameter Store keys updated by the workflow:
  - `/java-app/prod/backend-image-tag`
  - `/java-app/prod/frontend-image-tag`
  - `/java-app/prod/release-id`
- Rollout: ASG Instance Refresh with `min_healthy_percentage = 100`,
  `max_healthy_percentage = 200` (launch-before-terminate).
- Post-deploy: smoke against `https://java.talorlik.com:8443/health` (or
  `/actuator/health`).
- Rollback: re-run `app-deploy.yml` with the previous SHA as the dispatch
  input; do not delete ECR images.

## 7. AWS account topology and required GitHub repo vars

Two accounts:

- DEPLOYMENT: VPC, ALB, EC2/ASG, RDS, ECR, Secrets Manager, ACM cert, SES.
- DOMAIN: Route53 hosted zone for `talorlik.com`. Terraform reaches it via a
  second `aws` provider alias that assumes a DNS-write role.

Required GitHub repository variables (set in repo settings, not committed):

```
AWS_REGION
DEPLOYMENT_ACCOUNT_ID
DEPLOYMENT_ROLE_ARN
DOMAIN_ACCOUNT_ID
DOMAIN_ROUTE53_ROLE_ARN
HOSTED_ZONE_ID
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
- Branch/PR hints (inferred from `ci.yml` triggers; unverified - check repo
  rules): PRs run `ci.yml`; merging to `main` runs `infra-apply.yml` and
  `app-deploy.yml`.

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
- `docs/auxiliary/adr/0001..0006-*.md` - decisions: frontend stack, auth model, WAF,
  Ubuntu resolution, secret rotation, provider/account model.

## 12. Known gaps and unverifieds

- Spring Boot version: `pom.xml` parent is `3.5.0`; PROJECT_OVERVIEW cites
  `3.5.14` and `4.0.6` as upstream stable lines. (unverified - check docs.)
- Ubuntu AMI choice for the Launch Template: `resolute`/`26.04` vs
  `noble`/`24.04` LTS. PROJECT_OVERVIEW prefers latest LTS. (unverified -
  check Canonical SSM `/aws/service/canonical` paths in the target region.)
- Port mapping: ALB listener `8443` -> target `8080`. Frontend container in
  `docker-compose.prod.yml` should publish host `8080:80` (Nginx 80 inside,
  8080 on the host). Confirm in `app/docker/docker-compose.prod.yml` before
  changing ALB target group ports.
- Maven wrapper (`mvnw`) is not committed; CI uses system `mvn`. If a
  reproducible toolchain is needed, add `mvnw` rather than pinning Maven in
  CI alone.

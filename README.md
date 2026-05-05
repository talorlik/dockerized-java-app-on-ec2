# Java Signup Platform on AWS

Production-shaped reference deployment of a small Spring Boot signup app on
EC2 ASG behind a public ALB, fronted by Nginx, persisted in RDS MySQL, with
secrets in Secrets Manager, releases tracked in SSM Parameter Store, and
ship-by-merge CI/CD via GitHub Actions OIDC.

Public endpoint: `https://java.talorlik.com:8443`.

## Topology

```
Internet
  |
  | HTTPS :8443
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
  +-- frontend  Nginx, port 8080:80, /api/* -> backend
  +-- backend   Spring Boot 3.5, Java 21, JWT auth
  +-- CloudWatch Agent
  |
  | TCP 3306
  v
RDS MySQL (private DB subnets, Multi-AZ, encrypted)
```

## Repository layout

```
.
├── infra/
│   ├── bootstrap/         # one-time S3+KMS for remote state
│   └── envs/prod/         # main TF env: VPC, ALB, ASG, RDS, ECR, IAM, WAF, Route53, observability
├── app/
│   ├── backend/           # Spring Boot 3.5 / Java 21 / Maven
│   ├── frontend/          # Vanilla JS + Nginx
│   └── docker/            # docker-compose.local.yml + docker-compose.prod.yml + env.template
├── tests/e2e/             # Playwright suite
├── .github/workflows/     # ci.yml, infra-plan.yml, infra-apply.yml, app-deploy.yml
└── docs/                  # 00..05 setup + operations + security docs
```

## One-pass setup (target account)

1. Fork or clone this repository.
2. Choose a **DEPLOYMENT** AWS account and a **DOMAIN** AWS account (can be the same).
3. In DEPLOYMENT account create or identify the GitHub OIDC role (`github-role`) and
   trust the repository (see `docs/02-domain-account-dns.md`).
4. In DOMAIN account create the `route53-dns-manager-role` trust for the
   DEPLOYMENT account `github-role`. Hosted zone for `talorlik.com` lives here.
5. Issue ACM certificate for `java.talorlik.com` in DEPLOYMENT account (`us-east-1`).
6. Configure GitHub repo:
   - Variables: `AWS_REGION`, `DEPLOYMENT_ACCOUNT_ID`, `DOMAIN_ACCOUNT_ID`, `HOSTED_ZONE_ID`.
   - Secrets: `ACM_CERTIFICATE_ARN`, `DEPLOYMENT_ROLE_ARN`, `DOMAIN_ROUTE53_ROLE_ARN`, `GH_TOKEN` (PAT for cross-workflow if you ever need it).
7. Run `infra/bootstrap` once locally with admin credentials in DEPLOYMENT account.
   Copy the printed `backend_block_example` into `infra/envs/prod/backend.tf`.
8. Push to `main` (or open a PR). `infra-apply.yml` provisions everything;
   `app-deploy.yml` builds and rolls images on each subsequent push.
9. After first apply, retrieve admin bootstrap creds from Secrets Manager:
   ```
   aws secretsmanager get-secret-value --secret-id /java-app/prod/admin --query SecretString --output text
   ```
10. Hit `https://java.talorlik.com:8443`, log in as admin, create a regular user.

Detailed steps live in `docs/` 00 through 05.

## Decisions

Locked decisions in this delivery:

- Frontend: plain HTML/CSS/vanilla JS.
- Auth: JWT bearer in `Authorization` header (stateless, SPA-friendly, no CSRF surface).
- WAF: enabled (`aws_wafv2_web_acl` attached to ALB; managed Common + KnownBadInputs + SQLi + 2000 req/min IP rate limit).
- CSV export: included (`/api/admin/users.csv`).
- Spring Boot: `3.5.x` (Spring Boot 3.5.0 release line).
- Java: 21 LTS.
- Ubuntu: dynamic SSM lookup (`var.ubuntu_lts_codename`, default `noble` = 24.04 LTS) (unverified - check Canonical's SSM listing).
- Region: `us-east-1`.

ADRs in `docs/adr/`.

## Quality gates

`ci.yml` enforces, on every PR and feature push:

- backend `mvn verify` (Surefire unit + Failsafe integration with Testcontainers MySQL).
- Docker build of backend + frontend.
- `docker compose up` smoke test.
- Playwright E2E (smoke spec).
- Terraform fmt, validate, tflint, checkov.

Merge to `main` is blocked unless all required checks pass.

## Operations cheatsheet

- Logs (per instance): CloudWatch log group `/java-app/prod/app`.
- Dashboard: `java-app-prod-main` in CloudWatch.
- Alarms route to SNS topic `java-app-prod-alarms` (subscribe an email via `var.alarm_email`).
- ALB access logs: S3 bucket `java-app-prod-alb-logs-<account>`.
- Roll a release manually: `gh workflow run app-deploy.yml`.
- Restart on a single node: `aws ssm start-session --target <i-...>` then `cd /opt/java-app && docker compose restart`.

## License

See `LICENSE`.

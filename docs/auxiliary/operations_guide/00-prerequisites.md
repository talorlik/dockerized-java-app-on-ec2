# 00 - Prerequisites

## AWS

- A **DEPLOYMENT** AWS account where ALB, EC2, ASG, RDS, ECR, Secrets Manager,
  ACM, and KMS resources will live.
- A **DOMAIN** AWS account where the public Route53 hosted zone lives.
  May be the same account; in this delivery it is a separate account.
- IAM permissions for the operator running `infra/bootstrap` once:
  S3 + KMS + IAM admin in DEPLOYMENT.

## DNS

- Public hosted zone for `talorlik.com` in DOMAIN account.
- A role in DOMAIN account (e.g. `route53-dns-manager-role`) trusted by the
  DEPLOYMENT account's `github-role` to manage records under
  `java.talorlik.com` and `_amazonses.<subdomain>`.

## TLS

- ACM certificate for `java.talorlik.com` issued **in DEPLOYMENT account**
  in the same region as the ALB (`us-east-1`).

## CLI / runtime

| Tool       | Minimum version | Notes                                  |
| ---------- | --------------- | -------------------------------------- |
| Terraform  | 1.7.0           | Constrained to `>= 1.7.0, < 2.0.0` in `versions.tf` |
| AWS CLI    | 2.x             | Required for bootstrap and deploy      |
| Docker     | 24+             | Compose v2 plugin. Docker Desktop, OrbStack, or Colima all work |
| Java JDK   | 21              | Temurin recommended                    |
| Maven      | 3.9+            | Used by backend build                  |
| Node       | 22+ (CI uses 24)| Used by Playwright E2E                 |
| `jq`       | any             | Convenience parsing                    |
| `act`      | 0.2.66+         | nektos/act, only required for local workflow runs - see `06_LOCAL_ACT_RUNS.md` (unverified - check `act --version`) |

## GitHub

- Repository OIDC trust to DEPLOYMENT `github-role`.
- Repo variables: `AWS_REGION`, `DEPLOYMENT_ACCOUNT_ID`, `DOMAIN_ACCOUNT_ID`,
  `HOSTED_ZONE_ID`.
- Repo secrets: `ACM_CERTIFICATE_ARN`, `DEPLOYMENT_ROLE_ARN`,
  `DOMAIN_ROUTE53_ROLE_ARN`.
- GitHub Environment named `prod` (referenced by `infra-apply.yml`,
  `app-deploy.yml`, `infra-destroy.yml`, `app-destroy.yml`). Attach a
  required-reviewer protection rule to gate apply/destroy runs.

## Local execution (optional)

If you intend to run the workflows on your own machine via
`nektos/act` instead of (or in addition to) GitHub-hosted runners,
follow `06_LOCAL_ACT_RUNS.md`. That guide covers:

- Host-level shared Docker registry credentials at `~/.act/.secrets`
  (mode `600`), reusable across every repo's act runs.
- Per-repo files derived from the templates already in this repo:
  `.github/env.local.example`, `.github/secrets.local.example`,
  `.github/vars.local.example`. All three real siblings are
  gitignored.
- The exact `act workflow_dispatch ...` invocations for INFRA APPLY
  and INFRA DESTROY, including the
  `--secret-file <(cat ~/.act/.secrets ./.github/secrets.local)`
  process-substitution pattern that merges host-level and per-repo
  secrets in one stream.

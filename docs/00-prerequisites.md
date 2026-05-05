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
| Terraform  | 1.7.0           | Pinned `~> 1.7` in `versions.tf`       |
| AWS CLI    | 2.x             | Required for bootstrap and deploy      |
| Docker     | 24+             | Compose v2 plugin                      |
| Java JDK   | 21              | Temurin recommended                    |
| Maven      | 3.9+            | Used by backend build                  |
| Node       | 20+             | Used by Playwright E2E                 |
| `jq`       | any             | Convenience parsing                    |

## GitHub

- Repository OIDC trust to DEPLOYMENT `github-role`.
- Repo variables: `AWS_REGION`, `DEPLOYMENT_ACCOUNT_ID`, `DOMAIN_ACCOUNT_ID`,
  `HOSTED_ZONE_ID`.
- Repo secrets: `ACM_CERTIFICATE_ARN`, `DEPLOYMENT_ROLE_ARN`,
  `DOMAIN_ROUTE53_ROLE_ARN`, `GH_TOKEN`.

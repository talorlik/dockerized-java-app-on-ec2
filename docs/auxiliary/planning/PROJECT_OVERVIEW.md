# PROJECT OVERVIEW

## Target architecture

```text
Internet
  |
  | HTTPS :8443
  v
Route53 A alias: java.talorlik.com
  |
  v
Public ALB, ACM certificate in DEPLOYMENT account
  |
  | HTTP :8080
  v
Private EC2 Auto Scaling Group
  |
  | docker compose up -d
  |
  +-- frontend container: Nginx static UI, host port 8080
  +-- backend container: Spring Boot API, internal port 8080
  +-- CloudWatch Agent
  |
  | MySQL :3306
  v
Private RDS MySQL, central shared DB
```

Core production rule: EC2 instances must be stateless. Docker Compose runs the
frontend and backend. MySQL runs as RDS, not as a local production container.
Local development can use a `mysql` service in `docker-compose.local.yml`.

## Main technical decisions

| Area             | Decision                                                                                |
| ---------------- | --------------------------------------------------------------------------------------- |
| Backend          | Java Spring Boot, Maven, Spring Web, Spring Security, Spring Data JPA, Flyway, Actuator |
| Frontend         | Simple HTML/CSS/JS or React/Vite served by Nginx                                        |
| DB               | Amazon RDS MySQL in private DB subnets                                                  |
| Local DB         | MySQL container only for local development and CI integration tests                     |
| Runtime          | EC2 Auto Scaling Group + Launch Template + Docker Compose                               |
| Public access    | ALB listener on HTTPS `8443`, target group to EC2 port `8080`                           |
| DNS              | Route53 A alias: `java.talorlik.com` -> ALB DNS name                                    |
| CI/CD            | GitHub Actions using OIDC into existing `github-role`                                   |
| Deployment style | Push image to ECR, update release parameter, trigger ASG Instance Refresh               |
| Observability    | CloudWatch logs, metrics, alarms, ALB access logs, RDS metrics, app Actuator health     |

ALB supports HTTPS listeners with certificates and custom listener ports, and
target groups can forward to targets on any port in the `1-65535` range, so
`8443 -> 8080` is valid. ([AWS Documentation][1])

## Phase 0 - Repository and project structure

### Theory

The repository must let another person clone, configure, and deploy the whole
stack in their AWS account with minimal hidden assumptions.

### Technical structure

```text
dockerized-java-app-on-ec2/
├── README.md
├── docs/
│   ├── auxiliary/
│   │   └── operations_guide/
│   │       ├── 00-prerequisites.md
│   │       ├── 01-bootstrap-state.md
│   │       ├── 02-domain-account-dns.md
│   │       ├── 03-deployment.md
│   │       ├── 04-operations.md
│   │       └── 05-security-model.md
├── infra/
│   ├── bootstrap/
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── envs/
│       └── prod/
│           ├── backend.tf
│           ├── providers.tf
│           ├── versions.tf
│           ├── locals.tf
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           ├── network.tf
│           ├── security.tf
│           ├── secrets.tf
│           ├── rds.tf
│           ├── ecr.tf
│           ├── alb.tf
│           ├── asg.tf
│           ├── iam.tf
│           ├── observability.tf
│           └── route53.tf
├── app/
│   ├── backend/
│   │   ├── pom.xml
│   │   ├── Dockerfile
│   │   └── src/
│   ├── frontend/
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   └── src/
│   └── docker/
│       ├── docker-compose.local.yml
│       ├── docker-compose.prod.yml
│       └── env.template
├── tests/
│   └── e2e/
│       ├── package.json
│       └── playwright.config.ts
└── .github/
    └── workflows/
        ├── ci.yml
        ├── infra-plan.yml
        ├── infra-apply.yml
        └── app-deploy.yml
```

## Phase 1 - Terraform state foundation

### Theory - P1 - Terraform state foundation

Terraform state must be remote, encrypted, versioned, and locked. Since the
state is in the same account as deployment, use one S3 backend bucket in the
DEPLOYMENT account.

Terraform S3 native locking uses `use_lockfile = true`; DynamoDB locking is
deprecated in current Terraform documentation. ([HashiCorp Developer][2])

### Technical deliverables

Create `infra/bootstrap`:

- S3 bucket for Terraform state.
- Versioning enabled.
- Server-side encryption with KMS or SSE-S3.
- Public access block enabled.
- Bucket policy requiring TLS.
- Optional access logging.
- Backend config generated for `infra/envs/prod`.

Backend example:

```hcl
terraform {
  backend "s3" {
    bucket       = "tal-java-app-terraform-state-prod"
    key          = "java-app/prod/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

## Phase 2 - Provider, account, and permissions model

### Theory - P2 - Provider, account, and permissions model

There are two AWS accounts:

| Account            | Purpose                                                 |
| ------------------ | ------------------------------------------------------- |
| DEPLOYMENT account | VPC, ALB, EC2, ASG, RDS, ECR, Secrets Manager, ACM cert |
| DOMAIN account     | Hosted zone for `talorlik.com`                          |

The existing `github-role` in the DEPLOYMENT account handles infrastructure and
app deployment. For automated Route53 changes in the DOMAIN account, Terraform
needs a second provider alias that assumes a DNS-write role in the DOMAIN
account. Route53 supports alias records pointing to ELB load balancers,
including when the hosted zone and load balancer are in different AWS accounts
by entering the load balancer DNS name. ([AWS Documentation][3])

### Technical deliverables - P2 - Provider, account, and permissions model

```hcl
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "domain"
  region = var.aws_region

  assume_role {
    role_arn = var.domain_account_route53_role_arn
  }
}
```

Required setup documentation:

1. Create or identify `github-role` in DEPLOYMENT account.
2. Configure GitHub OIDC trust for the repository.
3. Create optional `route53-dns-manager-role` in DOMAIN account.
4. Allow DEPLOYMENT `github-role` to assume the DOMAIN DNS role.
5. Add GitHub repository variables:

   - `AWS_REGION`
   - `DEPLOYMENT_ACCOUNT_ID`
   - `DEPLOYMENT_ROLE_ARN`
   - `DOMAIN_ACCOUNT_ID`
   - `DOMAIN_ROUTE53_ROLE_ARN`
   - `HOSTED_ZONE_ID`
   - `ACM_CERTIFICATE_ARN`

GitHub OIDC to AWS uses `token.actions.githubusercontent.com` as the OIDC
provider and `sts.amazonaws.com` as the audience in standard AWS/GitHub setup.
([GitHub][4])

## Phase 3 - Network foundation

### Theory - P3 - Network foundation

Use a normal three-tier VPC:

```text
Public subnets:
  ALB, NAT gateways

Private app subnets:
  EC2 ASG instances

Private DB subnets:
  RDS MySQL subnet group
```

### Technical deliverables - P3 - Network foundation

Use `terraform-aws-modules/vpc/aws`.

Create:

- VPC across at least 2 AZs.
- Public subnets for ALB.
- Private app subnets for EC2.
- Private DB subnets for RDS.
- NAT gateway for outbound package/image access from EC2.
- VPC endpoints where useful:

  - `ssm`
  - `ssmmessages`
  - `ec2messages`
  - `secretsmanager`
  - `logs`
  - `ecr.api`
  - `ecr.dkr`
  - S3 gateway endpoint

Use module pinning. The Terraform AWS VPC module is the correct module family
for VPC construction and supports NAT gateway patterns. ([GitHub][5])

## Phase 4 - Security groups and baseline security

### Theory - P4 - Security groups and baseline security

Only the ALB is internet-facing. EC2 instances have no public inbound access.
RDS accepts traffic only from the application security group.

## Security group model

| Security group | Inbound                | Outbound                            |
| -------------- | ---------------------- | ----------------------------------- |
| ALB SG         | `0.0.0.0/0` TCP `8443` | App SG TCP `8080`                   |
| App SG         | ALB SG TCP `8080`      | RDS SG TCP `3306`, HTTPS `443`      |
| RDS SG         | App SG TCP `3306`      | None required for normal DB serving |

## EC2 hardening

- No SSH from the internet.
- Use SSM Session Manager for access.
- Enforce IMDSv2.
- Encrypted EBS root volume.
- Least-privilege instance profile.
- No secrets in user data.
- Docker daemon logs limited and rotated.
- Security patches installed on boot.

Session Manager avoids open inbound SSH ports, bastions, and SSH key management.
([AWS Documentation][6]) IMDSv2 can be enforced so IMDSv1 calls fail, reducing
metadata exposure risk. ([AWS Documentation][7])

## Phase 5 - Secrets and KMS

### Theory - P5 - Secrets and KMS

Secrets are generated once, stored centrally, read at runtime by EC2 through
IAM, and never committed to GitHub.

### Technical deliverables - P5 - Secrets and KMS

Create secrets:

| Secret                       | Purpose                                                    |
| ---------------------------- | ---------------------------------------------------------- |
| `/java-app/prod/db/app-user` | App DB username/password                                   |
| `/java-app/prod/admin`       | Seeded admin username/password                             |
| `/java-app/prod/jwt`         | JWT signing secret                                         |
| `/java-app/prod/ses`         | SES sender config if needed                                |
| `/java-app/prod/app-config`  | Non-secret runtime config if not using SSM Parameter Store |

Preferred DB master secret mode: let RDS manage the master password in Secrets
Manager. AWS RDS can generate and store the master password in Secrets Manager
and rotate it by default every seven days. ([AWS Documentation][8])

App user secret options:

1. Terraform creates app DB user password in Secrets Manager.
2. DB migration/init job creates the app user with least privilege.
3. Backend connects as app user, not master user.

## Phase 6 - Central MySQL DB

### Theory - P6 - Central MySQL DB

A central DB is mandatory because ASG instances are horizontally scaled and
replaceable. Local containerized MySQL would break consistency across instances.

### Technical deliverables - P6 - Central MySQL DB

Use `terraform-aws-modules/rds/aws`.

Create:

- RDS MySQL.
- Private DB subnet group.
- Multi-AZ enabled for production.
- Storage encryption enabled.
- Automated backups enabled.
- Deletion protection enabled.
- Minor version auto-upgrade according to policy.
- CloudWatch logs export for error/general/slow query logs as appropriate.
- Performance Insights or equivalent RDS monitoring.
- Storage autoscaling enabled.
- Parameter group:

  - enforce UTF-8 charset.
  - tune connection limits.
  - enable slow query logging.
- DB SG allows only App SG on `3306`.

RDS Multi-AZ provides failover support through standby DB instances, and
Multi-AZ DB clusters can include readable standby instances depending on
deployment type. ([AWS Documentation][9]) RDS performance guidance emphasizes
sizing RAM so the working set stays mostly in memory and using CloudWatch
ReadIOPS behavior to validate that. ([AWS Documentation][10]) RDS storage
autoscaling can automatically increase allocated storage when free space remains
low. ([AWS Documentation][11])

## Phase 7 - ECR and release metadata

### Theory - P7 - ECR and release metadata

Images must be immutable and traceable. Do not deploy `latest`.

### Technical deliverables - P7 - ECR and release metadata

Create:

- ECR repository for backend.
- ECR repository for frontend.
- ECR lifecycle policy.
- Image scanning enabled.
- Tag immutability enabled where compatible with workflow.
- SSM Parameter Store release pointers:

  - `/java-app/prod/backend-image-tag`
  - `/java-app/prod/frontend-image-tag`
  - `/java-app/prod/release-id`

GitHub Actions builds images, tags them by commit SHA, pushes them to ECR,
updates SSM release parameters, then starts ASG Instance Refresh.

Amazon ECR supports pushing Docker and OCI images to private repositories with
`docker push`, after registry authentication. ([AWS Documentation][12]) AWS
Prescriptive Guidance documents the GitHub Actions + Terraform + ECR pattern for
building and pushing Docker images. ([AWS Documentation][13])

## Phase 8 - ALB, TLS, and DNS

### Theory - P8 - ALB, TLS, and DNS

The public interface is the ALB. The EC2 instances only receive traffic from the
ALB.

### Technical deliverables - P8 - ALB, TLS, and DNS

Use `terraform-aws-modules/alb/aws`.

Create:

- Internet-facing ALB in public subnets.
- HTTPS listener on port `8443`.
- Existing ACM certificate ARN from DEPLOYMENT account.
- Target group:

  - protocol: HTTP
  - port: `8080`
  - target type: instance
  - health check path: `/health` or `/actuator/health`
- Access logs to S3.
- Idle timeout tuned for app behavior.
- Desync mitigation / drop invalid headers where appropriate.
- Optional WAF ACL attached later.

Route53:

```text
java.talorlik.com A alias -> ALB DNS name
```

ALB access logs capture request timing, client IP, latencies, paths, and
response codes, which is enough for lightweight HTTP observability without a
full observability stack. ([AWS Documentation][14])

## Phase 9 - EC2 Launch Template and Auto Scaling Group

### Theory - P9 - EC2 Launch Template and Auto Scaling Group

The Launch Template defines how every new instance becomes a working application
node. ASG ensures failed instances are replaced and scaled out/in.

### Technical deliverables - P9 - EC2 Launch Template and Auto Scaling Group

Use `terraform-aws-modules/autoscaling/aws`.

Create Launch Template:

- Latest Ubuntu AMI via Canonical SSM parameter.
- Instance type variable, for example `t3.small` or `t3.medium`.
- IAM instance profile.
- App SG.
- Encrypted EBS volume.
- IMDSv2 required.
- User data installs:

  - Docker Engine
  - Docker Compose plugin
  - AWS CLI
  - CloudWatch Agent
  - SSM Agent if not preinstalled
- User data pulls:

  - compose file from S3 or baked into user data
  - image tags from SSM
  - secrets from Secrets Manager
- User data runs:

  - `aws ecr get-login-password`
  - `docker compose pull`
  - `docker compose up -d`

Canonical publishes Ubuntu AMI IDs through public SSM Parameter Store under
`/aws/service/canonical`, and Canonical documents the latest Ubuntu LTS AMI
lookup path pattern. ([Ubuntu Documentation][15]) For latest Ubuntu in 2026, use
`resolute` or `26.04` if the account/region has it available; otherwise pin to
`noble` or `24.04` LTS. Canonical’s current SSM release list includes
`resolute`, `26.04`, `noble`, and `24.04`. ([Ubuntu Documentation][15])

Create ASG:

- Min capacity: `2`
- Desired capacity: `2`
- Max capacity: `4` or `6`
- Subnets: private app subnets
- Attached to ALB target group
- Health check type: ELB
- Health check grace period: enough for Docker pull and app startup
- Target tracking scaling:

  - ALB request count per target, or
  - average CPU utilization
- Instance refresh:

  - minimum healthy percentage: `100`
  - maximum healthy percentage: `200` for launch-before-terminate behavior
  - warmup/bake period configured

Target tracking scaling keeps a selected average utilization or throughput
metric near a target value. ([AWS Documentation][16]) ASG health checks can use
EC2 and ELB signals, and unhealthy instances are replaced to maintain desired
capacity. ([AWS Documentation][17]) Instance Refresh replaces instances in
batches and can launch new instances before terminating old ones when minimum
healthy percentage is `100`. ([AWS Documentation][18])

## Phase 10 - Docker Compose production runtime

### Theory - P10 - Docker Compose production runtime

Production Compose should orchestrate app containers only. The database is
external RDS.

## Production Compose

```yaml
services:
  backend:
    image: "${BACKEND_IMAGE}"
    restart: unless-stopped
    env_file:
      - /opt/java-app/.env
    expose:
      - "8080"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 15s
      timeout: 5s
      retries: 10

  frontend:
    image: "${FRONTEND_IMAGE}"
    restart: unless-stopped
    ports:
      - "8080:80"
    depends_on:
      backend:
        condition: service_healthy
```

Nginx frontend routes:

```nginx
location / {
  try_files $uri /index.html;
}

location /api/ {
  proxy_pass http://backend:8080/;
}
```

Docker restart policies are the correct container-level mechanism for restarting
containers after failures or Docker restarts. ([Docker Documentation][19])

## Phase 11 - Java backend implementation

### Theory - P11 - Java backend implementation

Keep the app simple but production-shaped: authentication, authorization,
validation, persistence, health endpoints, and idempotent initialization.

Spring Boot is appropriate because it is designed for standalone
production-grade Spring applications with minimal configuration. Current Spring
project metadata shows Spring Boot `4.0.6` as the latest stable line, with
`3.5.14` also available as a maintained 3.x line. ([Home][20])

## Backend features

Entities:

- `users`
- `roles`
- `verification_codes`
- `audit_events`

Core flows:

1. Signup.
2. Generate email verification code.
3. Store hashed verification code with expiry.
4. Send code through SES.
5. Verify code.
6. Login.
7. View profile.
8. Update profile except email.
9. Admin login.
10. Admin CRUD/list/search/filter/sort registrants.
11. Admin audit view.

Security:

- Spring Security.
- Password hashing with BCrypt or Argon2.
- CSRF protection if using cookie sessions.
- JWT if SPA/API separation is preferred.
- Role-based access:

  - `ROLE_USER`
  - `ROLE_ADMIN`
- Rate limit login and verification attempts at app level.
- Generic auth failure messages.
- Server-side input validation.
- Unique email constraint.

Spring Security documents BCrypt and Argon2 password encoders as adaptive
one-way functions that should be tuned to take roughly one second to verify on
the target system. ([Home][21]) OWASP also treats password storage as a
dedicated security control because stored passwords must remain protected even
if the DB is compromised. ([OWASP Cheat Sheet Series][22])

## DB initialization

Use Flyway for schema migrations:

```text
V1__create_users.sql
V2__create_roles.sql
V3__create_verification_codes.sql
V4__create_audit_events.sql
```

Seed admin through an idempotent application startup routine:

1. Read `/java-app/prod/admin` from Secrets Manager.
2. Check if admin email exists.
3. If missing, hash password.
4. Insert admin user in a transaction.
5. Assign `ROLE_ADMIN`.
6. Never log the password.

This avoids hard-coding admin credentials into SQL migrations.

## Phase 12 - Frontend implementation

### Theory - P12 - Frontend implementation

The frontend should be thin and boring. The backend owns security and
validation.

## Pages

| Page                    | Path               |
| ----------------------- | ------------------ |
| Signup                  | `/signup`          |
| Email verification      | `/verify`          |
| Signup success          | `/thank-you`       |
| Login                   | `/login`           |
| Profile                 | `/profile`         |
| Admin registrants table | `/admin/users`     |
| Admin user detail/edit  | `/admin/users/:id` |

Admin table features:

- Pagination.
- Search.
- Sort.
- Filter by verified/unverified.
- View created/updated timestamps.
- Disable/delete user.
- Reset verification status.
- Export CSV optional.

## Phase 13 - Email verification with SES

### Theory - P13 - Email verification with SES

Email verification is transactional mail, not marketing mail. Use SES with a
verified sender/domain.

### Technical deliverables - P13 - Email verification with SES

Create:

- SES identity for `talorlik.com` or `java.talorlik.com`.
- DKIM DNS records in DOMAIN account.
- Optional MAIL FROM domain.
- SES configuration set for bounce/complaint events.
- App IAM permission to send only from the approved identity.

SES domain identity verification requires DNS access and DKIM records. If DNS is
in Route53 in another account, the DKIM records must be added there. ([AWS
Documentation][23]) SES sandbox allows only limited sending, and production
access is required to send to arbitrary recipients. ([AWS Documentation][24])

## Phase 14 - Testing strategy

### Theory - P14 - Testing strategy

Deployment must be blocked unless all quality gates pass.

## Test layers

| Layer                 | Tool                                                        | Purpose                                         |
| --------------------- | ----------------------------------------------------------- | ----------------------------------------------- |
| Unit tests            | JUnit 5, Mockito                                            | Services, validation, security helpers          |
| Integration tests     | Maven Failsafe, Testcontainers MySQL                        | Repository, migrations, auth flows, DB behavior |
| API tests             | RestAssured or Spring MockMvc                               | Backend endpoint behavior                       |
| E2E tests             | Playwright                                                  | Signup, verification, login, profile, admin UI  |
| Container smoke tests | Docker Compose                                              | Full stack starts and health checks pass        |
| IaC checks            | `terraform fmt`, `validate`, `tflint`, `checkov` or `tfsec` | Terraform quality and security                  |

Testcontainers is built for JUnit tests with throwaway services such as MySQL,
and is especially useful for integration tests against real backing services
instead of mocks. ([Home][25]) Maven Failsafe runs integration tests during the
`integration-test` and `verify` lifecycle phases. ([maven.apache.org][26])
Playwright has official CI guidance for GitHub Actions. ([Playwright][27])

## Phase 15 - GitHub Actions CI/CD

### Theory - P15 - GitHub Actions CI/CD

CI validates code. CD deploys only validated artifacts. Infrastructure and
application deployment should be separate workflows.

## Workflow 1: `ci.yml`

Triggers:

- Pull request.
- Push to feature branches.

Jobs:

1. Backend unit tests.
2. Backend integration tests with Testcontainers.
3. Frontend lint/build.
4. Docker build.
5. Docker Compose smoke test.
6. Playwright E2E against local Compose stack.
7. Terraform fmt/validate/tflint/checkov.

Deployment is not allowed from this workflow.

## Workflow 2: `infra-plan.yml`

Triggers:

- Pull request touching `infra/**`.

Actions:

1. Assume DEPLOYMENT `github-role`.
2. `terraform init`.
3. `terraform fmt -check`.
4. `terraform validate`.
5. `terraform plan`.
6. Upload plan artifact or comment summary.

## Workflow 3: `infra-apply.yml`

Triggers:

- Merge to `main`.
- Manual dispatch.

Actions:

1. Assume DEPLOYMENT `github-role`.
2. Init.
3. Plan.
4. Apply.
5. Output ALB DNS, ASG name, ECR repository URLs, secret ARNs.

## Workflow 4: `app-deploy.yml`

Triggers:

- Merge to `main` after CI passes.
- Manual dispatch with image tag.

Actions:

1. Run all CI gates or depend on successful CI workflow.
2. Build backend image.
3. Build frontend image.
4. Push both to ECR with commit SHA.
5. Update SSM release parameters.
6. Start ASG Instance Refresh.
7. Poll refresh status.
8. Run post-deploy smoke test against `https://java.talorlik.com:8443/health`.

GitHub environments can add deployment protection rules and environment-scoped
secrets. ([GitHub Docs][28])

## Phase 16 - Observability using AWS services

### Theory - P16 - Observability using AWS services

This is not a full observability platform. The goal is enough visibility to
operate the app safely.

### Technical deliverables - P16 - Observability using AWS services

CloudWatch:

- CloudWatch Agent on EC2.
- Collect:

  - CPU, memory, disk.
  - Docker logs.
  - Nginx frontend logs.
  - Spring Boot backend logs.
  - `/var/log/cloud-init-output.log`.
- CloudWatch log groups with retention.
- CloudWatch dashboards:

  - ALB 5xx/4xx.
  - ALB target response time.
  - ASG desired/in-service instances.
  - EC2 CPU/memory/disk.
  - RDS CPU/free storage/connections/ReadIOPS/WriteIOPS.
  - App error count.

CloudWatch Agent can collect system metrics, custom metrics, logs, and traces
from EC2 and containerized applications. ([AWS Documentation][29])

Alarms:

| Alarm                       | Action                       |
| --------------------------- | ---------------------------- |
| ALB 5xx high                | SNS notification             |
| Target unhealthy count > 0  | SNS notification             |
| RDS CPU high                | SNS notification             |
| RDS free storage low        | SNS notification             |
| RDS connections high        | SNS notification             |
| EC2 disk high               | SNS notification             |
| ASG instance refresh failed | SNS/EventBridge notification |

Logs:

- ALB access logs to S3.
- Application logs to CloudWatch Logs.
- RDS logs exported to CloudWatch where supported.

## Phase 17 - Performance plan

## App layer

- Use HikariCP connection pooling.
- Keep backend stateless.
- Enable gzip/static compression at Nginx.
- Cache static assets with long cache headers and fingerprinted filenames.
- Use DB indexes:

  - `users.email`
  - `users.created_at`
  - `users.verified`
  - admin search fields as needed.
- Paginate admin queries.
- Avoid loading all users into memory.
- Use Actuator health readiness/liveness endpoints.

## EC2/ASG layer

- Start with `t3.small` or `t3.medium`.
- Desired capacity `2`.
- Scale on ALB request count per target or CPU.
- Configure warmup time.
- Avoid scaling below 2 in production.
- Use GP3 EBS.

## DB layer

- Use Multi-AZ for production.
- Enable storage autoscaling.
- Monitor working set via ReadIOPS.
- Add read replica only when admin/search reads become significant.
- Avoid premature Aurora unless the project grows.

## Phase 18 - Security plan

## Infrastructure security

- ALB public, EC2 private, RDS private.
- No public IP on EC2.
- No public RDS.
- SSM instead of SSH.
- Least-privilege IAM.
- IMDSv2 required.
- Encrypted S3, EBS, RDS, Secrets Manager.
- TLS termination at ALB.
- Security groups reference other SGs, not broad CIDRs.
- Terraform state bucket locked down.
- ALB access logging enabled.
- Secrets never printed in logs.

## Application security

- Password hashing with BCrypt/Argon2.
- Verification code stored hashed, not plaintext.
- Verification code expiry.
- Login throttling.
- Admin role enforcement on backend.
- Backend validation on every request.
- Secure cookies if using cookie sessions.
- CORS locked to `java.talorlik.com`.
- Security headers from Nginx:

  - `Strict-Transport-Security`
  - `X-Content-Type-Options`
  - `X-Frame-Options`
  - `Referrer-Policy`
  - `Content-Security-Policy`

## Phase 19 - Documentation for handoff

## Required docs

| Doc | Contents |
| --- | --- |
| `docs/auxiliary/operations_guide/00-prerequisites.md` | AWS account, GitHub repo, AWS CLI, Terraform, Docker, Java, Maven |
| `docs/auxiliary/operations_guide/01-bootstrap-state.md` | Create remote state bucket and backend |
| `docs/auxiliary/operations_guide/02-domain-account-dns.md` | Hosted zone, cross-account Route53 role, A alias, SES DKIM |
| `docs/auxiliary/operations_guide/03-deployment.md` | Full deploy sequence |
| `docs/auxiliary/operations_guide/04-operations.md` | Logs, alarms, SSM access, restart app, refresh ASG |
| `docs/auxiliary/operations_guide/05-security-model.md` | IAM, SGs, secrets, TLS, DB access |
| `README.md` | One-pass setup guide |

## Setup sequence for another AWS account

1. Fork/clone repo.
2. Create or choose AWS DEPLOYMENT account.
3. Create or choose DOMAIN account.
4. Create ACM certificate in DEPLOYMENT account for `java.talorlik.com`.
5. Validate ACM certificate using DNS records in DOMAIN account.
6. Create GitHub OIDC role or update existing `github-role`.
7. Create optional DOMAIN account Route53 role.
8. Configure GitHub repository variables.
9. Run `infra/bootstrap`.
10. Configure backend.
11. Run `infra/envs/prod`.
12. Confirm ALB target group health.
13. Confirm Route53 A alias resolves.
14. Confirm `https://java.talorlik.com:8443`.
15. Retrieve admin credentials from Secrets Manager.
16. Login as admin.
17. Verify signup and email verification.

## Phase 20 - Acceptance criteria

| Domain        | Acceptance criteria                                                   |
| ------------- | --------------------------------------------------------------------- |
| Network       | ALB is public, EC2/RDS are private                                    |
| TLS           | `java.talorlik.com:8443` serves HTTPS with ACM cert                   |
| Scaling       | ASG launches at least 2 instances across private subnets              |
| Self-healing  | Terminated instance is replaced and app becomes healthy automatically |
| Deployment    | New image tag triggers ASG Instance Refresh                           |
| DB            | All app instances use the same RDS MySQL database                     |
| Secrets       | Admin and DB credentials exist in Secrets Manager                     |
| Auth          | Signup, email verification, login, profile, admin flows work          |
| Tests         | Unit, integration, E2E, Compose smoke tests block failed deployments  |
| Observability | CloudWatch logs, metrics, alarms, ALB logs, RDS metrics exist         |
| Security      | No SSH ingress, no public RDS, IMDSv2 enforced, least-privilege IAM   |
| Handoff       | New user can deploy from README without undocumented manual steps     |

[1]:
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html
"Create an HTTPS listener for your Application Load Balancer - Elastic Load
Balancing"
[2]: https://developer.hashicorp.com/terraform/language/backend/s3 "Backend
Type: s3 | Terraform | HashiCorp Developer"
[3]:
https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html
"Routing traffic to an ELB load balancer - Amazon Route 53"
[4]:
https://github.com/aws-actions/configure-aws-credentials?utm_source=chatgpt.com
"Configure AWS credential environment variables for use ..."
[5]:
https://github.com/terraform-aws-modules/terraform-aws-vpc?utm_source=chatgpt.com
"AWS VPC Terraform module"
[6]:
https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html
"AWS Systems Manager Session Manager - AWS Systems Manager"
[7]:
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html
"Use the Instance Metadata Service to access instance metadata - Amazon Elastic
Compute Cloud"
[8]:
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-secrets-manager.html
"Password management with Amazon RDS and AWS Secrets Manager - Amazon Relational
Database Service"
[9]:
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html
"Configuring and managing a Multi-AZ deployment for Amazon RDS - Amazon
Relational Database Service"
[10]:
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html
"Best practices for Amazon RDS - Amazon Relational Database Service"
[11]:
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIOPS.Autoscaling.html?utm_source=chatgpt.com
"Managing capacity automatically with Amazon RDS storage ..."
[12]:
https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html
"Pushing a Docker image to an Amazon ECR private repository - Amazon ECR"
[13]:
https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/build-and-push-docker-images-to-amazon-ecr-using-github-actions-and-terraform.html
"Build and push Docker images to Amazon ECR using GitHub Actions and Terraform -
AWS Prescriptive Guidance"
[14]:
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
"Access logs for your Application Load Balancer - Elastic Load Balancing"
[15]:
https://documentation.ubuntu.com/aws/aws-how-to/instances/find-ubuntu-images/
"Find Ubuntu images on AWS - Ubuntu on AWS documentation"
[16]:
https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html
"Target tracking scaling policies for Amazon EC2 Auto Scaling - Amazon EC2 Auto
Scaling"
[17]:
https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html
"Health checks for instances in an Auto Scaling group - Amazon EC2 Auto Scaling"
[18]:
https://docs.aws.amazon.com/autoscaling/ec2/userguide/instance-refresh-overview.html
"How an instance refresh works in an Auto Scaling group - Amazon EC2 Auto
Scaling"
[19]:
https://docs.docker.com/engine/containers/start-containers-automatically/?utm_source=chatgpt.com
"Start containers automatically"
[20]: https://spring.io/projects/spring-boot "Spring Boot"
[21]:
https://docs.spring.io/spring-security/reference/features/authentication/password-storage.html
"Password Storage :: Spring Security"
[22]:
https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
"Password Storage - OWASP Cheat Sheet Series"
[23]: https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html
"Creating and verifying identities in Amazon SES - Amazon Simple Email Service"
[24]: https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html
"Request production access (Moving out of the Amazon SES sandbox) - Amazon
Simple Email Service"
[25]: https://docs.spring.io/spring-boot/reference/testing/testcontainers.html
"Testcontainers :: Spring Boot"
[26]:
https://maven.apache.org/surefire/maven-failsafe-plugin/?utm_source=chatgpt.com
"Introduction – Maven Failsafe Plugin"
[27]: https://playwright.dev/docs/ci-intro?utm_source=chatgpt.com "Setting up
CI"
[28]:
https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment
"Managing environments for deployment - GitHub Docs"
[29]:
https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html
"Collect metrics, logs, and traces using the CloudWatch agent - Amazon
CloudWatch"

# Engineering Execution Backlog

## Related Documents Index

- Product requirements baseline:
  `docs/auxiliary/planning/PRODUCT_REQUIREMENTS_DOCUMENT.md`
- Technical cross-reference and requirement IDs:
  `docs/auxiliary/planning/TECHNICAL_REQUIREMENTS_REFERENCE.md`
- Source architecture and phase design:
  `docs/auxiliary/planning/PROJECT_OVERVIEW.md`

Story-to-technical mapping is maintained in
`TECHNICAL_REQUIREMENTS_REFERENCE.md` Section 4
("Backlog To Technical Cross-Reference Matrix").

## 1. Purpose

This document translates the product requirements into an engineering-first
delivery backlog with:

- Epics aligned to platform domains
- Sprint-ready user stories
- Explicit acceptance tests for each story
- Suggested delivery sequence

## 2. Delivery Principles

- Infrastructure and application work proceed in parallel where safe.
- Security and observability are built in, not deferred.
- Each story is independently verifiable.
- No production deployment without passing quality gates.

## 3. Milestones

| Milestone | Goal | Exit Criteria |
| ---- | ---- | ---- |
| M1 | Foundation ready | Remote state, providers, VPC, SG baseline complete |
| M2 | Runtime online | ALB + ASG + RDS + Compose runtime healthy |
| M3 | Core app live | Signup, verify, login, profile complete |
| M4 | Admin + ops ready | Admin features, monitoring, alarms complete |
| M5 | Production hardening | Security controls, docs, handoff complete |

## 4. Epic 1 - Terraform Foundation

### Story E1-S1: Bootstrap Remote Terraform State

As a platform engineer, I want encrypted and locked remote Terraform state so
that infrastructure changes are reliable and collaborative.

Acceptance tests:

- `infra/bootstrap` creates S3 state bucket.
- Bucket versioning is enabled.
- Public access block is enabled.
- Bucket policy denies non-TLS requests.
- Backend configuration in `infra/envs/prod` uses S3 + lockfile.

### Story E1-S2: Configure Multi-Account Provider Model

As a platform engineer, I want deployment and domain providers so that Route53
changes can be managed across accounts.

Acceptance tests:

- Default AWS provider uses deployment account context.
- Aliased domain provider assumes DNS role ARN.
- Required repository variables are documented.
- OIDC role assumption works in CI test run.

### Story E1-S3: Create Baseline Environment Scaffolding

As a platform engineer, I want modular Terraform file structure so that each
domain can be developed independently.

Acceptance tests:

- `infra/envs/prod` includes domain files (`network.tf`, `security.tf`,
  `rds.tf`, `asg.tf`, `alb.tf`, etc.).
- `terraform init` and `terraform validate` pass in `infra/envs/prod`.

## 5. Epic 2 - Network And Security Baseline

### Story E2-S1: Build Three-Tier VPC

As a platform engineer, I want public, app-private, and db-private subnets so
that network exposure is minimized.

Acceptance tests:

- VPC spans at least 2 AZs.
- Public subnets host ALB and NAT.
- Private app subnets host EC2 ASG.
- Private DB subnets are used by RDS subnet group.

### Story E2-S2: Configure Security Group Policy

As a security-conscious operator, I want strict SG rules so that only allowed
traffic paths are possible.

Acceptance tests:

- ALB SG allows inbound TCP `8443` from internet.
- App SG allows inbound TCP `8080` only from ALB SG.
- RDS SG allows inbound TCP `3306` only from App SG.
- No broad inbound rule to EC2 or RDS from `0.0.0.0/0`.

### Story E2-S3: Add VPC Endpoints And Egress Strategy

As a platform engineer, I want private service connectivity so that app nodes
can fetch required AWS resources safely.

Acceptance tests:

- Required interface endpoints are provisioned (`ssm`, `ssmmessages`,
  `ec2messages`, `secretsmanager`, `logs`, `ecr.api`, `ecr.dkr`).
- S3 gateway endpoint is provisioned.
- Private app subnets can access required services without failures.

## 6. Epic 3 - Data, Secrets, And Registry

### Story E3-S1: Provision Secrets Model

As an application team, I want runtime secrets in Secrets Manager so that
credentials are never embedded in code or user data.

Acceptance tests:

- Secrets created for DB app user, admin bootstrap, JWT, and SES config.
- IAM policy allows app nodes to read only approved secret paths.
- Secret values do not appear in logs.

### Story E3-S2: Provision Production RDS

As a platform engineer, I want a resilient managed database so that app state
is durable and shared across instances.

Acceptance tests:

- RDS MySQL is deployed in private DB subnets.
- Multi-AZ is enabled.
- Storage encryption, backups, and deletion protection are enabled.
- DB SG only allows App SG on `3306`.

### Story E3-S3: Provision ECR And Release Parameter Keys

As a release engineer, I want immutable image registries and release pointers
so that deployments are auditable.

Acceptance tests:

- Backend and frontend ECR repositories exist.
- Lifecycle policies are configured.
- Image scanning is enabled.
- SSM parameters exist for backend tag, frontend tag, and release ID.

## 7. Epic 4 - Runtime Platform (ALB + ASG + Compose)

### Story E4-S1: Deploy Public ALB With TLS

As an end user, I want secure HTTPS access so that traffic is encrypted in
transit.

Acceptance tests:

- Internet-facing ALB exists in public subnets.
- HTTPS listener on port `8443` uses ACM certificate.
- Target group points to app instances on HTTP `8080`.
- Health check endpoint is configured.

### Story E4-S2: Configure Route53 Alias

As a user, I want stable domain access so that I can reach the app via
`java.talorlik.com`.

Acceptance tests:

- Route53 alias `A` record points to ALB DNS.
- DNS resolution returns ALB endpoint.
- HTTPS request to domain reaches healthy application response.

### Story E4-S3: Build Launch Template Hardening

As a platform engineer, I want secure immutable instance templates so that
nodes bootstrap consistently.

Acceptance tests:

- IMDSv2 required in launch template.
- EBS root volume encrypted.
- No SSH ingress dependency.
- User data installs Docker, Compose plugin, AWS CLI, CloudWatch Agent.

### Story E4-S4: Enable Auto Scaling Group Operations

As an operator, I want self-healing compute so that node failures do not cause
extended outages.

Acceptance tests:

- ASG desired capacity starts at 2.
- ASG is attached to ALB target group with ELB health checks.
- Instance refresh strategy configured for safe rollout.
- Terminating an instance causes automatic replacement.

### Story E4-S5: Implement Production Compose Runtime

As an application team, I want a deterministic runtime stack so that app
services start reliably on every node.

Acceptance tests:

- Compose runtime includes backend and frontend only.
- Frontend maps host `8080` to container `80`.
- Frontend proxies `/api` to backend service.
- Backend health endpoint reports healthy when app is ready.

## 8. Epic 5 - Backend Product Features

### Story E5-S1: Implement Core Domain Schema With Flyway

As a backend developer, I want versioned DB migrations so that schema evolution
is controlled and reproducible.

Acceptance tests:

- Flyway migrations create `users`, `roles`, `verification_codes`,
  `audit_events`.
- Fresh database initializes successfully.
- Repeat startup does not corrupt schema state.

### Story E5-S2: Implement Signup And Verification Flow

As an end user, I want to verify my email so that account activation is secure.

Acceptance tests:

- Signup endpoint creates user with pending verification.
- Verification code is generated, hashed, and stored with expiry.
- Verification endpoint activates user with valid code.
- Invalid/expired code returns safe error response.

### Story E5-S3: Implement Login And Profile Management

As a user, I want authenticated profile access so that I can manage account
details.

Acceptance tests:

- Verified users can log in.
- Unverified or invalid credentials are rejected.
- Authenticated user can view profile.
- User can update profile fields except email.

### Story E5-S4: Implement Role-Based Authorization

As a security engineer, I want strict role checks so that admin operations are
not accessible to regular users.

Acceptance tests:

- `ROLE_USER` and `ROLE_ADMIN` are enforced by backend authorization rules.
- Non-admin users receive forbidden responses for admin APIs.
- Admin users can access admin APIs.

### Story E5-S5: Implement Idempotent Admin Seeding

As an operator, I want bootstrap admin creation so that the system is usable
after first deploy without hardcoded credentials.

Acceptance tests:

- Startup reads admin secret from Secrets Manager.
- Admin is inserted only if not already present.
- Seed process assigns `ROLE_ADMIN`.
- Seed process logs no plaintext password.

## 9. Epic 6 - Frontend Product Features

### Story E6-S1: Implement Public Auth Pages

As an end user, I want simple auth pages so that signup, verification, and
login are straightforward.

Acceptance tests:

- `/signup`, `/verify`, `/thank-you`, and `/login` routes render and function.
- Form validation and error states are shown to users.
- API calls route through frontend proxy to backend.

### Story E6-S2: Implement User Profile Page

As an authenticated user, I want profile management UI so that I can view and
update personal details.

Acceptance tests:

- `/profile` route requires authentication.
- Profile fetch succeeds for logged-in user.
- Profile update excludes email modifications.

### Story E6-S3: Implement Admin User Management UI

As an admin, I want user management controls so that I can operate the system.

Acceptance tests:

- `/admin/users` supports pagination, search, sort, and verified filter.
- Admin can open detail page `/admin/users/:id`.
- Admin can disable/delete user and reset verification status.

## 10. Epic 7 - Email Verification Delivery

### Story E7-S1: Configure SES Identity And DNS

As a platform engineer, I want SES sender identity verified so that verification
emails are deliverable.

Acceptance tests:

- SES identity exists for configured domain/subdomain.
- Required DKIM records exist in Route53 hosted zone.
- SES account is approved for production sending where required.

### Story E7-S2: Implement Transactional Email Send Path

As a user, I want to receive verification email quickly so that onboarding is
not blocked.

Acceptance tests:

- Signup triggers SES send using approved sender identity.
- Bounce/complaint configuration set is attached where configured.
- Failed sends are logged with non-sensitive diagnostics.

## 11. Epic 8 - CI/CD And Release Automation

### Story E8-S1: Build CI Workflow

As a development team, I want automated quality checks so that regressions are
caught before merge.

Acceptance tests:

- `ci.yml` runs unit, integration, frontend build, Docker build, smoke, E2E,
  and IaC checks.
- CI failures block merge according to repository protection rules.
- Workflow does not perform deployment actions.

### Story E8-S2: Build Infrastructure Plan Workflow

As an infra reviewer, I want plan visibility in pull requests so that infra
changes are reviewable before apply.

Acceptance tests:

- `infra-plan.yml` triggers on `infra/**` PR changes.
- Plan output is uploaded or summarized in PR.

### Story E8-S3: Build Infrastructure Apply Workflow

As an operator, I want controlled infra applies so that production environment
updates are auditable.

Acceptance tests:

- `infra-apply.yml` triggers on main merge/manual dispatch.
- Init/plan/apply succeeds with OIDC role assumption.
- Key infrastructure outputs are emitted.

### Story E8-S4: Build Application Deploy Workflow

As a release engineer, I want image-based rollout automation so that app deploys
are repeatable and observable.

Acceptance tests:

- `app-deploy.yml` builds/pushes backend and frontend images tagged by SHA.
- Workflow updates SSM release parameter keys.
- Workflow starts and monitors ASG instance refresh.
- Post-deploy smoke test runs against production health endpoint.

## 12. Epic 9 - Observability And Operations

### Story E9-S1: Enable Logging And Metrics Collection

As an operator, I want centralized telemetry so that incidents are diagnosable.

Acceptance tests:

- CloudWatch Agent runs on EC2 instances.
- System, Docker, Nginx, Spring, and cloud-init logs are collected.
- Log retention is configured.

### Story E9-S2: Build Operational Dashboards

As an operations team, I want AWS dashboards so that service health is visible
at a glance.

Acceptance tests:

- Dashboards include ALB errors/latency, ASG health, EC2 utilization,
  RDS performance, and app error indicators.

### Story E9-S3: Configure Alerting

As an on-call engineer, I want actionable alarms so that I can respond quickly
to production risk.

Acceptance tests:

- Alarms exist for ALB 5xx, unhealthy targets, RDS CPU/storage/connections,
  EC2 disk, and instance refresh failures.
- Alarm actions route to SNS and/or EventBridge targets.

## 13. Epic 10 - Security Hardening And Governance

### Story E10-S1: Enforce Infrastructure Security Baseline

As a security reviewer, I want baseline controls enforced so that attack surface
is minimized.

Acceptance tests:

- EC2 has no public IP or SSH ingress requirement.
- RDS is private only.
- Encryption at rest enabled for state, disks, DB, and secrets.
- IMDSv2 enforced.

### Story E10-S2: Enforce Application Security Controls

As a security engineer, I want robust auth protections so that account takeover
risk is reduced.

Acceptance tests:

- Password hashing uses adaptive algorithm (BCrypt/Argon2).
- Verification codes are hashed and expire.
- Login/verification rate limiting is active.
- Generic auth failure messages prevent user enumeration.

### Story E10-S3: Apply HTTP Security Headers

As a security engineer, I want secure defaults at the web edge so that common
browser attack vectors are reduced.

Acceptance tests:

- Nginx emits required security headers:
  - `Strict-Transport-Security`
  - `X-Content-Type-Options`
  - `X-Frame-Options`
  - `Referrer-Policy`
  - `Content-Security-Policy`

## 14. Epic 11 - Documentation And Handoff

### Story E11-S1: Produce Deployment Documentation Set

As a new engineer, I want complete run docs so that I can deploy and operate
without tribal knowledge.

Acceptance tests:

- Required documents exist:
  - `docs/auxiliary/operations_guide/00-prerequisites.md`
  - `docs/auxiliary/operations_guide/01-bootstrap-state.md`
  - `docs/auxiliary/operations_guide/02-domain-account-dns.md`
  - `docs/auxiliary/operations_guide/03-deployment.md`
  - `docs/auxiliary/operations_guide/04-operations.md`
  - `docs/auxiliary/operations_guide/05-security-model.md`
  - `README.md`
- Documents are internally consistent with actual workflows.

### Story E11-S2: Validate New-Account End-To-End Setup

As a maintainer, I want reproducible handoff validation so that project
adoption succeeds in other AWS accounts.

Acceptance tests:

- A fresh operator can follow docs and deploy without undocumented steps.
- Domain, certificate, infrastructure, app deploy, and admin login succeed.
- Core user journey (signup to verification) succeeds in validation run.

## 15. Suggested Sprint Plan

| Sprint | Focus | Stories |
| ---- | ---- | ---- |
| Sprint 1 | Infra foundations | E1-S1..S3, E2-S1..S2 |
| Sprint 2 | Runtime platform | E2-S3, E3-S1..S3, E4-S1..S4 |
| Sprint 3 | App core | E4-S5, E5-S1..S4, E6-S1..S2 |
| Sprint 4 | Admin + email + CI/CD | E5-S5, E6-S3, E7-S1..S2, E8-S1..S4 |
| Sprint 5 | Ops + security + handoff | E9-S1..S3, E10-S1..S3, E11-S1..S2 |

## 16. Definition Of Done (Global)

A story is complete only when all are true:

- Code and infra changes are merged through reviewed pull request.
- Relevant automated tests pass in CI.
- Security checks pass with no unreviewed critical findings.
- Monitoring/logging impact is considered and implemented as needed.
- User-facing and operational docs are updated where impacted.
- Acceptance tests listed in this backlog are demonstrably satisfied.

## 17. Release Readiness Checklist

- Production endpoint responds over valid TLS on `:8443`.
- ASG has at least 2 healthy in-service instances.
- App uses shared RDS and required secrets.
- Core user and admin flows pass end-to-end test run.
- Alerting and dashboards are active.
- Handoff docs validated by a fresh run-through.

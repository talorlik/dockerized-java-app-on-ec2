# Product Requirements Document (PRD)

## 1. Document Control

- Product: Dockerized Java App Deployment Reference on AWS EC2
- Version: 1.0
- Status: Draft
- Source: `docs/auxiliary/planning/PROJECT_OVERVIEW.md`
- Primary environment: Production (`prod`)
- Primary domain: `java.talorlik.com`

## 2. Product Overview

This project provides a reference implementation for deploying Dockerized Java
applications on AWS EC2 with production-shaped infrastructure and operations.
The included signup and admin application is a sample workload used to validate
the deployment pattern end-to-end.

The system must be deployable by another engineer with minimal hidden
assumptions and complete operational documentation.

## 3. Objectives And Success Criteria

### 3.1 Business Objectives

- Provide a secure, production-capable Dockerized Java app deployment pattern.
- Enable repeatable infrastructure and app deployment through CI/CD.
- Ensure operations can monitor, diagnose, and recover the platform.
- Support cross-account DNS and domain ownership patterns.

### 3.2 Measurable Success Criteria

- HTTPS traffic serves successfully at `https://java.talorlik.com:8443`.
- At least 2 healthy app instances are running behind the ALB in production.
- Signup, verification, login, profile, and admin flows are end-to-end working.
- New container image releases roll out through ASG Instance Refresh.
- Failed quality gates block deployment in CI/CD workflows.
- Required logs, metrics, alarms, and dashboards exist in AWS.

## 4. Scope

### 4.1 In Scope

- Terraform-based AWS infrastructure in deployment and domain accounts.
- Backend API and frontend UI in Docker containers.
- RDS MySQL as central production database.
- Email verification using SES.
- GitHub Actions pipelines for CI, infra, and app deployment.
- Security baseline across network, IAM, secrets, and application controls.
- Operational dashboards, logs, and alarms.
- Handoff documentation and setup guides.

### 4.2 Out Of Scope

- Kubernetes/ECS/EKS orchestration.
- Full enterprise observability platform beyond AWS-native baseline.
- Multi-region active-active deployment.
- Marketing email workflows.
- Non-production environment matrix beyond local development and production.

## 5. Stakeholders And User Roles

- Platform engineer: provisions and maintains infrastructure.
- Application developer: implements backend/frontend features.
- Operations engineer: monitors, troubleshoots, and handles incidents.
- Admin user: manages registrants and audits activity.
- End user: signs up, verifies email, logs in, and manages profile.

## 6. Assumptions And Constraints

- Deployment account contains core runtime resources.
- Domain account hosts Route53 zone and may require cross-account role assume.
- Existing GitHub OIDC role (`github-role`) is available or will be created.
- ACM certificate exists in deployment account for target domain.
- Production compute instances are stateless.
- Production database is RDS MySQL and not containerized locally on EC2.

## 7. High-Level Architecture Requirements

### 7.1 Topology

- Public ALB receives internet HTTPS traffic on port `8443`.
- ALB forwards HTTP traffic on port `8080` to EC2 instances in private subnets.
- EC2 instances run Docker Compose with frontend and backend services.
- RDS MySQL runs in private DB subnets and is accessed only by app tier.
- Route53 `A` alias maps `java.talorlik.com` to ALB DNS.

### 7.2 Stateless Runtime

- EC2 instances must not hold persistent business state.
- New instances must self-bootstrap from declared config, image tags, and
  secrets.

## 8. Functional Requirements

### 8.1 FR-INFRA-01: Repository Structure

- System shall maintain a repository layout that cleanly separates:
  - Infrastructure (`infra/bootstrap`, `infra/envs/prod`)
  - Application (`app/backend`, `app/frontend`, `app/docker`)
  - Tests (`tests/e2e`)
  - GitHub workflows and deployment documentation

### 8.2 FR-INFRA-02: Terraform Remote State

- System shall store Terraform state remotely in S3 in deployment account.
- State backend shall be encrypted and versioned.
- State locking shall use S3 lockfile.
- State bucket shall deny non-TLS requests and block public access.

### 8.3 FR-INFRA-03: AWS Provider And Account Model

- Terraform shall support:
  - Default deployment-account AWS provider
  - Domain-account aliased provider for Route53 operations
- GitHub Actions shall assume deployment role via OIDC.
- Deployment role shall be able to assume domain DNS role when configured.

### 8.4 FR-INFRA-04: Network Foundation

- System shall deploy VPC across at least 2 AZs.
- Network shall include:
  - Public subnets (ALB/NAT)
  - Private app subnets (EC2)
  - Private DB subnets (RDS)
- Outbound access for app subnets shall be available via NAT and/or VPC
  endpoints.

### 8.5 FR-INFRA-05: Security Groups

- ALB SG shall allow inbound TCP `8443` from internet.
- App SG shall allow inbound TCP `8080` only from ALB SG.
- RDS SG shall allow inbound TCP `3306` only from App SG.

### 8.6 FR-INFRA-06: Compute Hardening

- EC2 instances shall not expose SSH to internet.
- Access shall use SSM Session Manager.
- Launch template shall require IMDSv2.
- Root volume shall be encrypted.
- User data shall not contain plaintext secrets.

### 8.7 FR-INFRA-07: Secrets Management

- Application runtime secrets shall be stored in Secrets Manager.
- Required secret domains shall include:
  - App DB user credentials
  - Admin bootstrap credentials
  - JWT signing secret
  - SES sender config where needed
- Secrets shall not be committed to source control.

### 8.8 FR-INFRA-08: Database Platform

- Production DB shall be RDS MySQL in private subnets.
- RDS shall be Multi-AZ in production.
- Storage encryption, backup, and deletion protection shall be enabled.
- App shall connect as least-privileged DB user, not DB master user.

### 8.9 FR-INFRA-09: Container Registry And Release Metadata

- Backend and frontend images shall be built and pushed to ECR.
- Deployments shall use immutable tags (commit SHA), not `latest`.
- Release pointers shall be stored in SSM Parameter Store.

### 8.10 FR-INFRA-10: ALB, TLS, And DNS

- Public ALB shall terminate TLS with ACM certificate.
- Listener shall use HTTPS on `8443`.
- Target group shall forward HTTP `8080` to app instances.
- Route53 shall publish alias `A` record for `java.talorlik.com`.

### 8.11 FR-INFRA-11: Auto Scaling Runtime

- ASG shall run in private app subnets.
- Production baseline capacity shall be 2 desired instances.
- ASG shall attach to ALB target group and use ELB health checks.
- ASG shall support target tracking and instance refresh rollout strategy.

### 8.12 FR-APP-01: Docker Compose Production Runtime

- Production Compose shall include backend and frontend services only.
- Backend shall expose internal service port `8080`.
- Frontend shall publish host port `8080` and proxy `/api` to backend.
- Backend health endpoint shall be used for container dependency checks.

### 8.13 FR-APP-02: Authentication And Registration

- End users shall be able to sign up with unique email and password.
- System shall generate email verification code with expiration.
- Verification codes shall be stored hashed.
- Users shall verify email before full authenticated access.
- Users shall be able to log in and view profile.
- Users shall be able to update profile except email.

### 8.14 FR-APP-03: Authorization

- System shall enforce role-based access controls.
- Required roles:
  - `ROLE_USER`
  - `ROLE_ADMIN`
- Admin endpoints and UI shall be inaccessible to non-admin users.

### 8.15 FR-APP-04: Admin Management

- Admin shall be able to list users with pagination.
- Admin shall be able to search and sort users.
- Admin shall be able to filter by verification state.
- Admin shall be able to view created/updated timestamps.
- Admin shall be able to disable/delete users.
- Admin shall be able to reset verification status.
- CSV export may be provided as optional capability.

### 8.16 FR-APP-05: Backend Data Model

- Backend persistence shall include:
  - `users`
  - `roles`
  - `verification_codes`
  - `audit_events`
- Schema changes shall be managed through Flyway migrations.

### 8.17 FR-APP-06: Admin Bootstrap

- Application shall perform idempotent admin seed at startup:
  - Read admin credentials from Secrets Manager
  - Create admin account only if absent
  - Assign `ROLE_ADMIN`
  - Never log plaintext credentials

### 8.18 FR-APP-07: Frontend Pages

- Frontend shall provide the following routes:
  - `/signup`
  - `/verify`
  - `/thank-you`
  - `/login`
  - `/profile`
  - `/admin/users`
  - `/admin/users/:id`

### 8.19 FR-APP-08: Email Delivery

- System shall send verification emails through SES using verified identity.
- DKIM records shall be configured in domain account DNS.
- App IAM policy shall restrict sender identity usage.

### 8.20 FR-CICD-01: CI Validation Workflow

- CI workflow shall run on pull requests and feature branch pushes.
- CI shall include:
  - Backend unit tests
  - Backend integration tests
  - Frontend lint/build
  - Docker build
  - Docker Compose smoke tests
  - Playwright E2E tests
  - Terraform quality/security checks
- CI workflow shall not perform production deployment.

### 8.21 FR-CICD-02: Infrastructure Plan Workflow

- Infra plan workflow shall trigger on `infra/**` pull request changes.
- Workflow shall run terraform init/fmt/validate/plan.
- Plan output shall be published as artifact or PR summary.

### 8.22 FR-CICD-03: Infrastructure Apply Workflow

- Infra apply workflow shall trigger on `main` merges or manual dispatch.
- Workflow shall perform init/plan/apply and publish key outputs.

### 8.23 FR-CICD-04: Application Deploy Workflow

- App deploy workflow shall trigger after validated main merges or manually.
- Workflow shall:
  - Build and push backend/frontend images
  - Update release parameters in SSM
  - Start and monitor ASG instance refresh
  - Execute post-deploy smoke checks

### 8.24 FR-OPS-01: Logging, Monitoring, And Alerting

- CloudWatch Agent shall collect system and app logs/metrics from EC2.
- CloudWatch dashboards shall include ALB, ASG, EC2, RDS, and app indicators.
- Alerting shall notify on high-severity ALB, RDS, EC2, and ASG conditions.
- ALB access logs shall be written to S3.

### 8.25 FR-DOC-01: Handoff Documentation

- Project shall include setup and operations docs enabling third-party
  deployment in a new AWS account.
- Documentation shall cover prerequisites, bootstrap, DNS, deployment,
  operations, and security model.

## 9. Non-Functional Requirements

### 9.1 Availability And Reliability

- Production runtime shall maintain minimum 2 healthy app instances.
- Failed EC2 instances shall be replaced automatically by ASG.
- Database shall be configured for production-grade failover (Multi-AZ).
- Deployment strategy shall support rolling replacement without full downtime.

### 9.2 Security

- No direct public inbound access to EC2 or RDS.
- Secrets shall be centrally managed and not logged.
- Passwords and verification codes shall be stored with secure hashing controls.
- Authentication failures shall use non-revealing error responses.
- Login and verification endpoints shall be rate-limited.
- Network controls shall rely on SG references over broad CIDRs.

### 9.3 Performance

- Backend shall use connection pooling.
- Admin list/search operations shall be paginated and indexed.
- Static assets shall be cacheable and compressed where appropriate.
- Health and startup timing shall be compatible with ASG grace periods.

### 9.4 Operability

- Required logs and metrics shall be retained for operational troubleshooting.
- Operational runbooks shall define restart, access, and incident triage steps.
- Deployment and runtime states shall be observable via AWS native services.

### 9.5 Maintainability

- Infrastructure and application changes shall be version controlled.
- Schema evolution shall be migration-driven.
- Module and dependency versions shall be pinned according to policy.

## 10. Data Requirements

- Email must be unique per user.
- User role assignments must be explicit and queryable.
- Verification records must include expiry and verification state.
- Audit events must capture admin and sensitive state-change operations.
- Timestamps for created/updated records must be available for admin workflows.

## 11. API And Integration Requirements

- Backend shall expose health endpoint for ALB and container health checks.
- Frontend shall call backend APIs through `/api` reverse proxy path.
- Backend shall integrate with:
  - RDS MySQL
  - Secrets Manager
  - SES
  - CloudWatch logging/metrics interfaces where applicable

## 12. Compliance And Governance Requirements

- IAM policies shall follow least privilege.
- Encryption at rest shall be enabled for S3, EBS, RDS, and secrets services.
- TLS shall be enforced for public ingress.
- Terraform state storage must be protected by access and transport controls.

## 13. Test And Quality Requirements

- Unit tests shall cover core services, validation, and security helpers.
- Integration tests shall validate DB behaviors with MySQL-compatible runtime.
- API tests shall verify endpoint correctness and auth behavior.
- E2E tests shall validate critical user and admin flows.
- Compose smoke tests shall validate runtime startup and health.
- Infrastructure checks shall validate formatting, correctness, and security
  posture.
- Deployment promotion shall be blocked when any required gate fails.

## 14. Release Requirements

- Every deployable image shall be traceable to a source commit SHA.
- Release metadata shall be stored in centralized parameter keys.
- Rollout shall use instance refresh with health-aware replacement.
- Post-deploy smoke test shall validate externally reachable health endpoint.

## 15. Risks And Mitigations

- Cross-account DNS complexity
  - Mitigation: provider alias design and explicit role-assumption docs.
- Secret sprawl and accidental disclosure
  - Mitigation: Secrets Manager standard paths, no secret logging, CI checks.
- Deployment drift between infra and app pipelines
  - Mitigation: separated workflows with explicit sequencing and release IDs.
- Runtime startup failures due to image pull/config issues
  - Mitigation: health checks, refresh monitoring, rollback-ready release tags.
- SES sandbox or sender identity misconfiguration
  - Mitigation: explicit production access and identity verification checklist.

## 16. Acceptance Requirements

Product shall be accepted when all below are true in production:

- Network architecture: ALB public, EC2 and RDS private.
- TLS endpoint: `java.talorlik.com:8443` serves valid HTTPS certificate.
- Scaling baseline: minimum 2 ASG instances across private app subnets.
- Self-healing: terminated instance is replaced and re-enters healthy state.
- Deployment path: new image tag initiates successful ASG instance refresh.
- Shared data layer: all app instances use same RDS MySQL backend.
- Secrets readiness: required admin and DB secrets exist and are retrievable by
  authorized principals.
- Application behavior: signup, verification, login, profile, and admin flows
  operate correctly.
- Quality gates: failed tests or checks block deployment.
- Observability baseline: required logs, metrics, dashboards, and alarms exist.
- Security baseline: no SSH ingress, no public RDS, IMDSv2 enforced, IAM least
  privilege applied.
- Handoff readiness: a new engineer can deploy from docs without undocumented
  manual steps.

## 17. Traceability Matrix (Condensed)

| Domain | Primary Requirement IDs |
| ------ | ----------------------- |
| Infrastructure foundation | FR-INFRA-01..11 |
| Application and identity | FR-APP-01..08 |
| CI/CD | FR-CICD-01..04 |
| Operations and observability | FR-OPS-01 |
| Documentation and handoff | FR-DOC-01 |

## 18. Open Decisions

- Final frontend implementation approach: plain HTML/CSS/JS vs React/Vite.
- Final auth session model: cookie session + CSRF vs JWT token pattern.
- Whether optional WAF ACL is required for initial production release.
- Whether CSV export is mandatory in v1 or deferred.

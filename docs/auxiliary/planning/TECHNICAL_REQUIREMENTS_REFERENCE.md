# Technical Requirements Reference

## 1. Purpose

This document is the technical source of truth for implementation details behind
the delivery stories in
`docs/auxiliary/planning/ENGINEERING_EXECUTION_BACKLOG.md`.

It is optimized for both humans and models by using:

- Stable technical requirement IDs (`TR-*`)
- Explicit story cross-references (`E#-S#`)
- Verification-oriented acceptance checks (`VT-*`)
- Consistent component ownership (`infra`, `app`, `ops`, `security`, `docs`)

## 2. How To Use This Document

- Start with the story in the backlog (example: `E4-S3`).
- Find it in the cross-reference matrix in Section 4.
- Follow linked technical sections and requirement IDs.
- Execute and validate using the verification tests listed in each section.

## 3. System Technical Context

### 3.1 Production Architecture

- Ingress path: Internet -> Route53 alias -> ALB HTTPS `8443` -> EC2 HTTP `8080`
- Runtime: Docker Compose on private ASG instances
- Services:
  - Frontend container (Nginx static site and reverse proxy)
  - Backend container (Spring Boot API)
  - CloudWatch Agent (host-level telemetry)
- Persistence: shared private RDS MySQL
- Core constraint: EC2 instances are stateless and replaceable

### 3.2 AWS Account Model

- Deployment account: VPC, ALB, EC2, ASG, RDS, ECR, Secrets Manager, ACM
- Domain account: Route53 hosted zone for `talorlik.com`
- CI/CD auth model: GitHub OIDC assumes deployment role, optionally assumes
  domain DNS role

### 3.3 Delivery Model

- Infrastructure as code: Terraform
- App delivery: images pushed to ECR using commit SHA tags
- Rollout: update release metadata and trigger ASG Instance Refresh
- Quality gate: deployment blocked on failed CI requirements

## 4. Backlog To Technical Cross-Reference Matrix

| Backlog Story | Technical Sections | Primary Requirement IDs | Primary Verification IDs |
| ---- | ---- | ---- | ---- |
| E1-S1 | 5.1 | TR-STATE-001..005 | VT-STATE-001..004 |
| E1-S2 | 5.2 | TR-ACCT-001..004 | VT-ACCT-001..003 |
| E1-S3 | 5.3 | TR-IAC-001..003 | VT-IAC-001..002 |
| E2-S1 | 6.1 | TR-NET-001..004 | VT-NET-001..003 |
| E2-S2 | 6.2 | TR-SG-001..004 | VT-SG-001..004 |
| E2-S3 | 6.3 | TR-NET-005..007 | VT-NET-004..005 |
| E3-S1 | 7.1 | TR-SEC-001..005 | VT-SEC-001..003 |
| E3-S2 | 7.2 | TR-DB-001..008 | VT-DB-001..004 |
| E3-S3 | 7.3 | TR-REL-001..005 | VT-REL-001..003 |
| E4-S1 | 8.1 | TR-ALB-001..004 | VT-ALB-001..003 |
| E4-S2 | 8.2 | TR-DNS-001..002 | VT-DNS-001..002 |
| E4-S3 | 8.3 | TR-LT-001..006 | VT-LT-001..003 |
| E4-S4 | 8.4 | TR-ASG-001..006 | VT-ASG-001..004 |
| E4-S5 | 8.5 | TR-RT-001..005 | VT-RT-001..003 |
| E5-S1 | 9.1 | TR-BE-001..004 | VT-BE-001..003 |
| E5-S2 | 9.2 | TR-BE-005..009 | VT-BE-004..006 |
| E5-S3 | 9.3 | TR-BE-010..013 | VT-BE-007..009 |
| E5-S4 | 9.4 | TR-BE-014..016 | VT-BE-010..011 |
| E5-S5 | 9.5 | TR-BE-017..020 | VT-BE-012..013 |
| E6-S1 | 10.1 | TR-FE-001..004 | VT-FE-001..002 |
| E6-S2 | 10.2 | TR-FE-005..007 | VT-FE-003..004 |
| E6-S3 | 10.3 | TR-FE-008..011 | VT-FE-005..006 |
| E7-S1 | 11.1 | TR-EMAIL-001..004 | VT-EMAIL-001..002 |
| E7-S2 | 11.2 | TR-EMAIL-005..007 | VT-EMAIL-003..004 |
| E8-S1 | 12.1 | TR-CI-001..004 | VT-CI-001..002 |
| E8-S2 | 12.2 | TR-CI-005..006 | VT-CI-003 |
| E8-S3 | 12.3 | TR-CI-007..009 | VT-CI-004 |
| E8-S4 | 12.4 | TR-CI-010..014 | VT-CI-005..006 |
| E9-S1 | 13.1 | TR-OBS-001..004 | VT-OBS-001..002 |
| E9-S2 | 13.2 | TR-OBS-005..006 | VT-OBS-003 |
| E9-S3 | 13.3 | TR-OBS-007..009 | VT-OBS-004 |
| E10-S1 | 14.1 | TR-HARD-001..004 | VT-HARD-001..002 |
| E10-S2 | 14.2 | TR-HARD-005..009 | VT-HARD-003..004 |
| E10-S3 | 14.3 | TR-HARD-010..011 | VT-HARD-005 |
| E11-S1 | 15.1 | TR-DOC-001..003 | VT-DOC-001 |
| E11-S2 | 15.2 | TR-DOC-004..005 | VT-DOC-002 |

## 5. Epic 1 Technical Requirements (Terraform Foundation)

### 5.1 Remote State Foundation (`E1-S1`)

Requirements:

- `TR-STATE-001`: Terraform state must use S3 backend in deployment account.
- `TR-STATE-002`: State bucket must enforce server-side encryption.
- `TR-STATE-003`: State bucket must enable versioning.
- `TR-STATE-004`: State bucket must block public access.
- `TR-STATE-005`: Backend locking must use `use_lockfile = true`.

Verification:

- `VT-STATE-001`: `terraform init` resolves S3 backend without local state.
- `VT-STATE-002`: S3 bucket policy denies non-TLS requests.
- `VT-STATE-003`: Versioning status is `Enabled`.
- `VT-STATE-004`: Parallel plan operation demonstrates lock behavior.

### 5.2 Provider And Role Model (`E1-S2`)

Requirements:

- `TR-ACCT-001`: Default provider targets deployment account.
- `TR-ACCT-002`: Aliased provider `aws.domain` assumes DNS role ARN.
- `TR-ACCT-003`: GitHub OIDC trust supports repository workflow identity.
- `TR-ACCT-004`: Repository variables define AWS region, account, role, zone,
  and certificate values.

Verification:

- `VT-ACCT-001`: CI workflow can assume deployment role.
- `VT-ACCT-002`: Terraform can read/write Route53 with `aws.domain`.
- `VT-ACCT-003`: Deny behavior confirmed when DNS role assume is removed.

### 5.3 Terraform Environment Scaffolding (`E1-S3`)

Requirements:

- `TR-IAC-001`: `infra/envs/prod` must separate domains into dedicated files.
- `TR-IAC-002`: Provider and backend blocks must be version-pinned.
- `TR-IAC-003`: Root module must validate with no schema errors.

Verification:

- `VT-IAC-001`: `terraform fmt -check` and `terraform validate` pass.
- `VT-IAC-002`: `terraform plan` creates coherent dependency graph.

## 6. Epic 2 Technical Requirements (Network And Security Baseline)

### 6.1 Three-Tier Network (`E2-S1`)

Requirements:

- `TR-NET-001`: VPC spans at least two availability zones.
- `TR-NET-002`: Public subnets host ALB and NAT.
- `TR-NET-003`: Private app subnets host ASG instances.
- `TR-NET-004`: Private DB subnets define RDS subnet group.

Verification:

- `VT-NET-001`: Route tables align public/private intent.
- `VT-NET-002`: ASG instance ENIs appear only in private app subnets.
- `VT-NET-003`: RDS subnet group includes only private DB subnets.

### 6.2 Security Group Routing Policy (`E2-S2`)

Requirements:

- `TR-SG-001`: ALB SG allows inbound `8443` from `0.0.0.0/0`.
- `TR-SG-002`: App SG allows inbound `8080` only from ALB SG.
- `TR-SG-003`: RDS SG allows inbound `3306` only from App SG.
- `TR-SG-004`: No direct public ingress to EC2 or RDS.

Verification:

- `VT-SG-001`: External scan shows ALB-only public listener.
- `VT-SG-002`: Direct connection from internet to app tier fails.
- `VT-SG-003`: DB access works from app tier.
- `VT-SG-004`: DB access fails from non-app security group.

### 6.3 Endpoint And Egress Design (`E2-S3`)

Requirements:

- `TR-NET-005`: Interface endpoints include SSM, logs, secrets, and ECR.
- `TR-NET-006`: S3 gateway endpoint exists for private subnet data access.
- `TR-NET-007`: Private app nodes can retrieve runtime dependencies.

Verification:

- `VT-NET-004`: Node bootstrap succeeds without egress timeout failures.
- `VT-NET-005`: Secrets/ECR/CloudWatch access succeeds from private instance.

## 7. Epic 3 Technical Requirements (Data, Secrets, Registry)

### 7.1 Secrets Architecture (`E3-S1`)

Requirements:

- `TR-SEC-001`: Secrets paths must be namespaced under `/java-app/prod/*`.
- `TR-SEC-002`: Required secrets include DB app user, admin, JWT, and SES.
- `TR-SEC-003`: Application IAM role allows least-privilege read access only.
- `TR-SEC-004`: No secrets may be hardcoded in source, workflow logs, or user
  data.
- `TR-SEC-005`: Secret rotation strategy must be documented.

Verification:

- `VT-SEC-001`: Secrets exist and are retrievable only by authorized principal.
- `VT-SEC-002`: Unauthorized role attempts return access denied.
- `VT-SEC-003`: Log inspection confirms no plaintext secret output.

### 7.2 RDS MySQL Platform (`E3-S2`)

Requirements:

- `TR-DB-001`: RDS MySQL runs in private DB subnets.
- `TR-DB-002`: Multi-AZ enabled for production deployment.
- `TR-DB-003`: Storage encrypted and backups enabled.
- `TR-DB-004`: Deletion protection enabled.
- `TR-DB-005`: DB security group restricts inbound to App SG only.
- `TR-DB-006`: Performance observability enabled (CloudWatch and/or insights).
- `TR-DB-007`: Parameter group enforces UTF-8 and slow query logging.
- `TR-DB-008`: App uses non-master least-privileged DB credentials.

Verification:

- `VT-DB-001`: DB endpoint reachable only from app network path.
- `VT-DB-002`: Backup retention and deletion protection flags are enabled.
- `VT-DB-003`: Slow query logs export and metric ingestion are visible.
- `VT-DB-004`: Login with app user works; master credential not required by app.

### 7.3 Registry And Release Metadata (`E3-S3`)

Requirements:

- `TR-REL-001`: Separate ECR repositories for backend and frontend.
- `TR-REL-002`: Image tags are immutable release identifiers (commit SHA).
- `TR-REL-003`: Registry scanning enabled.
- `TR-REL-004`: Lifecycle policy enforces retention controls.
- `TR-REL-005`: SSM release keys track backend tag, frontend tag, and release
  ID.

Verification:

- `VT-REL-001`: Push of SHA-tagged images succeeds to both repositories.
- `VT-REL-002`: Release keys update atomically during deploy workflow.
- `VT-REL-003`: Deploy consumes release keys and resolves correct image tags.

## 8. Epic 4 Technical Requirements (Runtime Platform)

### 8.1 ALB TLS Edge (`E4-S1`)

Requirements:

- `TR-ALB-001`: ALB is internet-facing in public subnets.
- `TR-ALB-002`: HTTPS listener runs on `8443` with ACM certificate.
- `TR-ALB-003`: Target group forwards to instance targets on `8080`.
- `TR-ALB-004`: Health check path uses backend health endpoint.

Verification:

- `VT-ALB-001`: TLS handshake and certificate chain are valid.
- `VT-ALB-002`: Healthy targets appear in target group.
- `VT-ALB-003`: Unhealthy app instance is marked unhealthy and replaced.

### 8.2 DNS Alias Routing (`E4-S2`)

Requirements:

- `TR-DNS-001`: `java.talorlik.com` alias `A` points to ALB DNS name.
- `TR-DNS-002`: DNS records are maintained in domain account hosted zone.

Verification:

- `VT-DNS-001`: DNS resolution returns ALB alias response.
- `VT-DNS-002`: HTTPS request to domain reaches expected application endpoint.

### 8.3 Launch Template Hardening (`E4-S3`)

Requirements:

- `TR-LT-001`: Launch template enforces IMDSv2.
- `TR-LT-002`: Root EBS volume encryption enabled.
- `TR-LT-003`: No SSH dependency in node operations path.
- `TR-LT-004`: User data installs Docker Engine, Compose plugin, AWS CLI.
- `TR-LT-005`: User data installs CloudWatch Agent and SSM Agent (if needed).
- `TR-LT-006`: User data fetches release metadata and secrets at runtime.

Verification:

- `VT-LT-001`: Instance metadata options show IMDSv2 required.
- `VT-LT-002`: Bootstrap logs confirm installation and runtime startup.
- `VT-LT-003`: Instance management works via Session Manager.

### 8.4 Auto Scaling And Self-Healing (`E4-S4`)

Requirements:

- `TR-ASG-001`: ASG desired capacity baseline is 2.
- `TR-ASG-002`: ASG attached to ALB target group with ELB health checks.
- `TR-ASG-003`: Health grace period covers image pull and app startup.
- `TR-ASG-004`: Target tracking policy uses CPU or ALB request metric.
- `TR-ASG-005`: Instance refresh uses launch-before-terminate posture.
- `TR-ASG-006`: Refresh progress is observable in deployment workflow.

Verification:

- `VT-ASG-001`: Manual termination causes replacement to healthy state.
- `VT-ASG-002`: Scale policy reacts to induced load profile.
- `VT-ASG-003`: Instance refresh completes with zero full-service outage.
- `VT-ASG-004`: Failed refresh path emits alertable event.

### 8.5 Compose Runtime Contract (`E4-S5`)

Requirements:

- `TR-RT-001`: Production compose includes only frontend and backend services.
- `TR-RT-002`: Frontend publishes `8080:80`.
- `TR-RT-003`: Frontend proxies `/api` to backend service name.
- `TR-RT-004`: Backend health endpoint used for container readiness.
- `TR-RT-005`: Container restart policy set to `unless-stopped`.

Verification:

- `VT-RT-001`: `docker compose up -d` starts both services successfully.
- `VT-RT-002`: `/api` routes from frontend to backend.
- `VT-RT-003`: Restart/reboot recovers service automatically.

## 9. Epic 5 Technical Requirements (Backend)

### 9.1 Schema And Persistence (`E5-S1`)

Requirements:

- `TR-BE-001`: Flyway controls all schema migrations.
- `TR-BE-002`: Core tables include `users`, `roles`, `verification_codes`,
  `audit_events`.
- `TR-BE-003`: Unique email constraint enforced at DB level.
- `TR-BE-004`: Migration execution is idempotent and repeat-safe.

Verification:

- `VT-BE-001`: Fresh DB runs migrations without error.
- `VT-BE-002`: Repeat startup does not reapply completed migrations.
- `VT-BE-003`: Duplicate email insertion fails by design.

### 9.2 Signup And Verification (`E5-S2`)

Requirements:

- `TR-BE-005`: Signup creates unverified user record.
- `TR-BE-006`: Verification code generated and stored in hashed form.
- `TR-BE-007`: Verification code has expiration enforcement.
- `TR-BE-008`: SES email dispatch triggered after signup.
- `TR-BE-009`: Invalid or expired verification attempts return generic failure.

Verification:

- `VT-BE-004`: Signup API persists pending user and verification artifact.
- `VT-BE-005`: Valid verification activates user account.
- `VT-BE-006`: Expired code path rejects request and keeps account unverified.

### 9.3 Authentication And Profile (`E5-S3`)

Requirements:

- `TR-BE-010`: Login accepts verified users with valid credentials.
- `TR-BE-011`: Unverified users are denied login.
- `TR-BE-012`: Authenticated profile read is available.
- `TR-BE-013`: Profile update excludes email field modifications.

Verification:

- `VT-BE-007`: Verified credentials return authenticated session/token.
- `VT-BE-008`: Unverified or invalid credentials are rejected.
- `VT-BE-009`: Profile update attempts on email field are denied or ignored.

### 9.4 Authorization Model (`E5-S4`)

Requirements:

- `TR-BE-014`: Roles include `ROLE_USER` and `ROLE_ADMIN`.
- `TR-BE-015`: Admin endpoints require `ROLE_ADMIN`.
- `TR-BE-016`: Authorization failures are logged without sensitive details.

Verification:

- `VT-BE-010`: Non-admin user receives forbidden on admin endpoints.
- `VT-BE-011`: Admin user can perform authorized admin operations.

### 9.5 Admin Seed Logic (`E5-S5`)

Requirements:

- `TR-BE-017`: Startup reads admin bootstrap secret.
- `TR-BE-018`: Admin account created only when absent.
- `TR-BE-019`: Seed transaction assigns admin role atomically.
- `TR-BE-020`: Seed logs must not contain secret value.

Verification:

- `VT-BE-012`: First startup creates admin account and role mapping.
- `VT-BE-013`: Subsequent startup does not create duplicate admin.

## 10. Epic 6 Technical Requirements (Frontend)

### 10.1 Public Auth Screens (`E6-S1`)

Requirements:

- `TR-FE-001`: Implement routes `/signup`, `/verify`, `/thank-you`, `/login`.
- `TR-FE-002`: Forms include client-side validation and server error rendering.
- `TR-FE-003`: API requests are routed through Nginx `/api` proxy.
- `TR-FE-004`: Success/failure messaging avoids exposing sensitive auth details.

Verification:

- `VT-FE-001`: Public route render and submit flows pass E2E checks.
- `VT-FE-002`: API network calls target expected backend paths via proxy.

### 10.2 Profile Screen (`E6-S2`)

Requirements:

- `TR-FE-005`: `/profile` requires authenticated state.
- `TR-FE-006`: Profile data retrieval and update are supported.
- `TR-FE-007`: Email field is read-only or otherwise non-updatable.

Verification:

- `VT-FE-003`: Anonymous access to `/profile` redirects or denies.
- `VT-FE-004`: Authenticated user updates allowed fields successfully.

### 10.3 Admin User Management UI (`E6-S3`)

Requirements:

- `TR-FE-008`: `/admin/users` supports pagination, search, sort, and filter.
- `TR-FE-009`: `/admin/users/:id` provides detail and edit actions.
- `TR-FE-010`: UI supports disable/delete and verification reset actions.
- `TR-FE-011`: Admin views are inaccessible to non-admin users.

Verification:

- `VT-FE-005`: Admin E2E suite validates list/detail/update/delete flows.
- `VT-FE-006`: Non-admin user cannot access admin pages.

## 11. Epic 7 Technical Requirements (Email)

### 11.1 SES Identity And DNS (`E7-S1`)

Requirements:

- `TR-EMAIL-001`: SES identity must be verified for configured sender domain.
- `TR-EMAIL-002`: DKIM DNS records must exist in domain hosted zone.
- `TR-EMAIL-003`: Production SES sending access enabled where required.
- `TR-EMAIL-004`: Sender IAM policy restricted to approved identity.

Verification:

- `VT-EMAIL-001`: SES identity and DKIM status are verified.
- `VT-EMAIL-002`: Test send from approved identity succeeds.

### 11.2 Transactional Send Path (`E7-S2`)

Requirements:

- `TR-EMAIL-005`: Signup flow triggers verification email send request.
- `TR-EMAIL-006`: Optional SES configuration set supports bounce/complaint data.
- `TR-EMAIL-007`: Send failures produce actionable non-sensitive telemetry.

Verification:

- `VT-EMAIL-003`: Signup in test environment emits SES send event.
- `VT-EMAIL-004`: Failure simulation records expected error signals.

## 12. Epic 8 Technical Requirements (CI/CD)

### 12.1 CI Workflow (`E8-S1`)

Requirements:

- `TR-CI-001`: `ci.yml` runs backend unit/integration and frontend checks.
- `TR-CI-002`: CI includes Docker build and compose smoke tests.
- `TR-CI-003`: CI includes E2E tests and IaC checks.
- `TR-CI-004`: CI has no production deployment side effects.

Verification:

- `VT-CI-001`: CI run shows all required jobs and pass/fail gating.
- `VT-CI-002`: Merge blocked when mandatory checks fail.

### 12.2 Infra Plan Workflow (`E8-S2`)

Requirements:

- `TR-CI-005`: `infra-plan.yml` triggers on infra pull requests.
- `TR-CI-006`: Plan output is exported for review.

Verification:

- `VT-CI-003`: Infra PR produces readable terraform plan output artifact.

### 12.3 Infra Apply Workflow (`E8-S3`)

Requirements:

- `TR-CI-007`: `infra-apply.yml` triggers on main merge or manual dispatch.
- `TR-CI-008`: Workflow performs init, plan, apply under assumed role.
- `TR-CI-009`: Workflow emits critical infrastructure outputs.

Verification:

- `VT-CI-004`: Successful apply run produces expected outputs.

### 12.4 App Deploy Workflow (`E8-S4`)

Requirements:

- `TR-CI-010`: Build backend/frontend images per commit SHA.
- `TR-CI-011`: Push images to ECR and update SSM release keys.
- `TR-CI-012`: Trigger ASG instance refresh and monitor progress.
- `TR-CI-013`: Run post-deploy smoke check at public health endpoint.
- `TR-CI-014`: Deploy workflow depends on successful quality gates.

Verification:

- `VT-CI-005`: Deploy run updates running instances to target release ID.
- `VT-CI-006`: Post-deploy check confirms healthy endpoint response.

## 13. Epic 9 Technical Requirements (Observability)

### 13.1 Telemetry Collection (`E9-S1`)

Requirements:

- `TR-OBS-001`: CloudWatch Agent installed and configured on app nodes.
- `TR-OBS-002`: Collect system metrics (CPU/memory/disk).
- `TR-OBS-003`: Collect app and container logs (Nginx, backend, Docker,
  cloud-init).
- `TR-OBS-004`: Configure log retention policies.

Verification:

- `VT-OBS-001`: Logs from all required sources are visible in CloudWatch.
- `VT-OBS-002`: Host metric streams populate dashboard widgets.

### 13.2 Dashboards (`E9-S2`)

Requirements:

- `TR-OBS-005`: Dashboard includes ALB errors/latency and ASG capacity health.
- `TR-OBS-006`: Dashboard includes EC2 and RDS performance indicators.

Verification:

- `VT-OBS-003`: Dashboard loads complete widget set with current metrics.

### 13.3 Alerting (`E9-S3`)

Requirements:

- `TR-OBS-007`: Alarms for ALB 5xx and unhealthy target counts.
- `TR-OBS-008`: Alarms for RDS CPU, storage, and connection stress.
- `TR-OBS-009`: Alarms for EC2 disk pressure and ASG refresh failure.

Verification:

- `VT-OBS-004`: Alarm action route to SNS/EventBridge validated by test trigger.

## 14. Epic 10 Technical Requirements (Security Hardening)

### 14.1 Infrastructure Security Controls (`E10-S1`)

Requirements:

- `TR-HARD-001`: EC2 instances remain private with no public ingress path.
- `TR-HARD-002`: RDS remains private and unreachable from internet.
- `TR-HARD-003`: Encryption at rest enabled for S3, EBS, RDS, secrets.
- `TR-HARD-004`: IMDSv2 mandatory on all compute launch templates.

Verification:

- `VT-HARD-001`: External connectivity checks validate no direct EC2/RDS access.
- `VT-HARD-002`: Resource encryption settings are enabled across all services.

### 14.2 Application Security Controls (`E10-S2`)

Requirements:

- `TR-HARD-005`: Password storage uses adaptive hash algorithm.
- `TR-HARD-006`: Verification codes are hashed at rest.
- `TR-HARD-007`: Verification tokens expire and are enforced.
- `TR-HARD-008`: Login/verification flows are rate-limited.
- `TR-HARD-009`: Authentication errors are generic and non-enumerating.

Verification:

- `VT-HARD-003`: Pen-test style checks confirm expected auth hardening behavior.
- `VT-HARD-004`: Security-focused integration tests pass.

### 14.3 Edge Security Headers (`E10-S3`)

Requirements:

- `TR-HARD-010`: Nginx includes standard security headers.
- `TR-HARD-011`: Header policy is regression-tested in deployment smoke suite.

Verification:

- `VT-HARD-005`: Response header inspection confirms required policy set.

## 15. Epic 11 Technical Requirements (Documentation And Handoff)

### 15.1 Required Documents (`E11-S1`)

Requirements:

- `TR-DOC-001`: Required handoff documents exist and are complete.
- `TR-DOC-002`: README includes one-pass setup orientation.
- `TR-DOC-003`: Operational and security runbooks match deployed behavior.

Verification:

- `VT-DOC-001`: Documentation review checklist passes with no blocking gaps.

### 15.2 New Account Validation (`E11-S2`)

Requirements:

- `TR-DOC-004`: Fresh operator can deploy from docs without hidden steps.
- `TR-DOC-005`: Validation run confirms domain, deploy, admin login, and user
  onboarding flow.

Verification:

- `VT-DOC-002`: End-to-end dry run in new account succeeds.

## 16. Canonical Runtime Parameters And Ports

### 16.1 Service Ports

- ALB listener: `8443` (HTTPS)
- App target group: `8080` (HTTP)
- Frontend host mapping: `8080:80`
- Backend app port: `8080`
- RDS MySQL: `3306`

### 16.2 Canonical Paths And Keys

- Domain endpoint: `java.talorlik.com`
- Secrets namespace: `/java-app/prod/*`
- Release metadata keys:
  - `/java-app/prod/backend-image-tag`
  - `/java-app/prod/frontend-image-tag`
  - `/java-app/prod/release-id`

## 17. Global Exit Criteria (Cross-Story)

All epics are complete only when:

- Functional story acceptance tests pass.
- Corresponding technical verification tests (`VT-*`) pass.
- CI gates are green and required checks enforced.
- Security baseline controls are active and validated.
- Operational dashboards/alerts exist and are actionable.
- Handoff documentation supports fresh-account deployment.

## 18. Machine Discovery Conventions

This document intentionally uses:

- Story key tokens (`E1-S1`, `E8-S4`, etc.)
- Technical requirement tokens (`TR-*`)
- Verification tokens (`VT-*`)
- Stable section headings mapped in matrix tables

Recommended retrieval queries:

- "technical requirements for E4-S4"
- "TR-ASG in technical reference"
- "verification tests for E10-S2"
- "cross-reference for E8-S1"

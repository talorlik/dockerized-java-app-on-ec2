# Slide Deck Instructions (Presenter Deck)

Generate a **10-slide minimalist presenter deck** for a **15-minute technical deep-dive** on a **reference implementation for deploying a Dockerized Java app on AWS EC2**. All content must be grounded in this project's Markdown documentation.

## Objective

Walk the audience from problem and solution through the deployment model, network and security boundaries, CI/CD release flow, cross-account DNS trust, observability, and operational end-state - emphasizing **why** decisions were made, not just what was built.

## Visual Theme

**Futuristic Minimalist:** Black/dark slate backgrounds; neon blue/cyan or gold accents. Abstract visuals (network flows, trust boundaries, container/runtime layers). Minimal text per slide; visuals support the speaker.

## Per-Slide Requirements

1. **Visual Focus** - One core diagram or concept.
2. **Minimalist Text** - >=5 short bullets (scannable).
3. **Speaker Script** - 2-3 sentences the presenter can say aloud.

## Mandatory Categories (~10 Slides)

**1. Problem &amp; Solution** - Need: reliable, secure, scalable deployment pattern for a Java signup app with clear operations and repeatable delivery. Solution: Terraform-managed AWS foundation, EC2 Auto Scaling Group runtime, Docker Compose for app containers, RDS MySQL for shared state, and GitHub Actions CI/CD. *Why* this balance of simplicity, control, and production-readiness.

**2. Target Architecture &amp; Traffic Flow** - Route53 alias `java.talorlik.com` -> public ALB on `8443` -> private EC2 ASG on `8080`; frontend Nginx container proxies `/api/` to Spring Boot backend; backend uses RDS MySQL, Secrets Manager, and SES. *Why* private compute + public edge, and why ALB `8443 -> 8080` is intentional.

**3. Infrastructure Foundation &amp; State Strategy** - Terraform bootstrap for remote S3 backend with locking; `infra/envs/prod` split by concern (`network.tf`, `security.tf`, `rds.tf`, `ecr.tf`, `alb.tf`, `asg.tf`, `iam.tf`, `route53.tf`, `observability.tf`). *Why* remote state hardening, modular infrastructure files, and controlled evolution.

**4. Runtime Model: Stateless EC2 + Docker Compose** - ASG instances are replaceable nodes; production Compose runs frontend + backend only; database is external RDS; release pointers in Parameter Store select immutable ECR image tags. *Why* stateless hosts simplify scaling, rollback, and instance refresh.

**5. Security Boundaries &amp; Identity** - ALB is only internet ingress; EC2 and RDS are private; no SSH (SSM Session Manager instead); IMDSv2 required; secrets in Secrets Manager; least-privilege IAM roles. *Why* reduced attack surface and safer operations.

**6. Cross-Account DNS Trust Model** - Deployment account hosts compute/data; domain account hosts Route53 zone; GitHub OIDC assumes deployment role, then optionally domain DNS role for Route53 changes. *Why* account separation and least-privilege trust for DNS automation.

**7. Delivery Pipeline &amp; Release Mechanism** - `ci.yml` gates quality; `infra-plan.yml` validates infra changes; `infra-apply.yml` applies infra on main/manual; `app-deploy.yml` builds SHA-tagged images, pushes to ECR, updates SSM release keys, and triggers ASG instance refresh. *Why* immutable artifacts + controlled rollout.

**8. Data, Auth, and App Lifecycle** - Spring Boot + JWT auth, Flyway migrations, user signup and verification flow, admin seeding from Secrets Manager, MySQL as single source of truth across all instances. *Why* consistency, secure credential handling, and predictable schema lifecycle.

**9. Observability &amp; Operational Controls** - CloudWatch Agent for logs/metrics, ALB access logs to S3, dashboards/alarms across ALB-ASG-EC2-RDS-app health, and post-deploy smoke validation. *Why* enough visibility for safe operations without overengineering.

**10. Conclusion - End-State &amp; Operations** - End-state: HTTPS service available at `java.talorlik.com:8443`, at least two healthy private app instances, shared private RDS, secure secret handling, and repeatable deployment/runbook process. *Why* this defines "production done" and supports safe day-2 operations.

## Narrative Focus (Why)

- **Stateless EC2 + shared RDS:** Horizontal scaling and predictable failover behavior.
- **ALB edge + private subnets:** Strong network isolation with standard web ingress.
- **OIDC + cross-account DNS role:** Automated delivery with explicit trust boundaries.
- **Immutable SHA images + instance refresh:** Safer rollouts and fast rollback by release pointer.
- **CloudWatch + alarms + smoke checks:** Operational confidence and faster incident response.

## Data Grounding

**All content must come from this project's docs.** Source of truth includes `docs/auxiliary/planning/PROJECT_OVERVIEW.md`, `docs/auxiliary/architecture/ARCHITECTURE.md`, `docs/auxiliary/operations_guide/00-prerequisites.md` through `docs/auxiliary/operations_guide/05-security-model.md`, ADRs under `docs/auxiliary/adr/`, relevant workflow files under `.github/workflows/`, and `README.md`. Do not add or contradict details from these documents.

**Important:** Base the entire deck on this documentation. Slide count, categories, and narrative must align with the EC2-based architecture, security model, deployment/release flow, cross-account DNS trust, and operational procedures defined in the cited files.

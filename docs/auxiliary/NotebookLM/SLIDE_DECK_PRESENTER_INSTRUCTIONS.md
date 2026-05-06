# Slide Deck Instructions (Presenter Deck)

Generate a **10-slide minimalist presenter deck** for a **15-minute technical deep-dive** on this project's **Dockerized Java app on AWS EC2** architecture. Use only documented project facts.

## Objective

Explain problem -> architecture -> delivery -> operations, with emphasis on **why** each design choice exists.

## Visual Theme

**Futuristic Minimalist:** Dark background, blue/cyan or gold accents, abstract infra visuals. Keep text light; visuals support narration.

## Per-Slide Requirements

1. **Visual Focus** - One core diagram or concept.
2. **Minimalist Text** - >=5 short bullets (scannable).
3. **Speaker Script** - 2-3 sentences the presenter can say aloud.

## Mandatory Categories (~10 Slides)

**1. Problem &amp; Solution** - Need a secure, scalable, repeatable Java app platform. Solution uses Terraform, EC2 ASG, Docker Compose, RDS MySQL, and GitHub Actions. Explain *why* this pragmatic stack.

**2. Target Architecture &amp; Traffic Flow** - `java.talorlik.com` -> ALB `8443` -> EC2 ASG `8080`; Nginx frontend proxies `/api/` to Spring Boot; backend uses RDS, Secrets Manager, SES. Explain *why* edge/public + compute/private split.

**3. Infrastructure Foundation &amp; State Strategy** - Terraform remote S3 state with locking; production infra files split by concern. Explain *why* state safety and modular IaC matter.

**4. Runtime Model** - Stateless EC2 nodes run frontend + backend containers; RDS is external; SSM release pointers select immutable ECR tags. Explain *why* this simplifies scaling and rollback.

**5. Security Boundaries &amp; Identity** - ALB is only internet ingress; EC2/RDS private; no SSH (SSM instead); IMDSv2 enforced; secrets in Secrets Manager; least-privilege IAM. Explain *why* this reduces attack surface.

**6. Cross-Account DNS Trust** - Deployment account hosts app infra; domain account hosts Route53; OIDC role chaining handles DNS updates. Explain *why* separation + least privilege.

**7. CI/CD &amp; Release Flow** - `ci.yml`, `infra-plan.yml`, `infra-apply.yml`, `app-deploy.yml`; build SHA-tagged images, push ECR, update SSM keys, trigger ASG refresh. Explain *why* immutable releases.

**8. Data &amp; Auth Lifecycle** - Spring Boot + JWT, Flyway migrations, signup/verification/login/admin flows, secret-driven admin seed, shared MySQL. Explain *why* consistency and secure bootstrapping.

**9. Observability &amp; Operations** - CloudWatch metrics/logs, ALB logs to S3, key alarms/dashboards, post-deploy smoke checks. Explain *why* this is sufficient for safe day-2 operations.

**10. Conclusion: End-State** - HTTPS at `java.talorlik.com:8443`, >=2 healthy app instances, private RDS, secure secrets, repeatable runbooks. Define what "production done" means.

## Narrative Focus (Why)

- **Stateless EC2 + shared RDS:** predictable scaling and recovery.
- **Public ALB + private compute/data:** secure default network posture.
- **OIDC + scoped cross-account role:** auditable DNS automation.
- **SHA images + ASG refresh:** controlled rollout and rollback.
- **CloudWatch + alarms + smoke tests:** fast detection and validation.

## Data Grounding

**All content must come from this project's docs.** Primary sources: `docs/auxiliary/planning/PROJECT_OVERVIEW.md`, `docs/auxiliary/architecture/ARCHITECTURE.md`, `docs/auxiliary/operations_guide/00-prerequisites.md` to `docs/auxiliary/operations_guide/05-security-model.md`, ADRs in `docs/auxiliary/adr/`, `.github/workflows/`, and `README.md`.

**Important:** Do not invent details. Keep slide count, categories, and narrative aligned with the documented EC2 architecture, security model, release flow, DNS trust model, and runbooks.

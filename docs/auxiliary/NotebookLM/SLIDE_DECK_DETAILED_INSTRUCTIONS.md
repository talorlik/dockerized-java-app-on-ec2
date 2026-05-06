# Slide Deck Instructions (Detailed)

Generate a **15-20 slide technical reference deck** for a **Dockerized Java app
on AWS (EC2 + ALB + RDS) reference implementation**. Keep it self-contained for stakeholders
reading without a presenter.

## Objective

Cover end-to-end architecture: Terraform provisioning in `infra/envs/prod`,
network and security boundaries, CI/CD and deployment flow, state and data
persistence, and secrets/identity - grounded in this repository's docs.

## Visual Theme

**"Secure Cloud Platform Blueprint."** Neon blue/cyan AWS icons, industrial
platform diagrams, glowing security motifs (shields/locks), dark slate
backgrounds, and subtle data-flow grid accents.

## Per-Slide Structure

1. **Clear title** (one line).
2. **3-5 technical bullets** (high information density).
3. **One key insight** sentence ("so what" for this slide).

## Mandatory Categories (All Six)

### 1. Terraform Foundation and Environment Topology

- **Single production Terraform root:** `infra/envs/prod` manages VPC, ALB,
  ASG/Launch Template, EC2 IAM, RDS MySQL, ECR, Secrets Manager, Route53,
  observability, and supporting policies.
- **State backend:** S3 remote state with
  **`use_lockfile = true`** (S3 native locking, no DynamoDB lock table).
  Include state durability controls and operational expectations.
- **Module-driven composition:** Emphasize pinned AWS modules and explicit
  dependencies across networking, compute, data, and DNS/TLS resources.

### 2. Multi-Account Security and DNS Trust Boundaries

- **Two-account model:** Deployment account hosts runtime infrastructure
  (ALB/EC2/RDS/ECR/Secrets/ACM). Domain account hosts Route53 zone.
- **Role chain design:** GitHub Actions OIDC assumes deployment `github-role`;
  Terraform then assumes cross-account DNS role for Route53 updates only.
- **Least privilege focus:** DNS permissions scoped to the target hosted zone
  and required record operations for `java.talorlik.com`.

### 3. Runtime Architecture - ALB, EC2, Containers, and Data Path

- **Traffic flow:** Internet → ALB HTTPS listener on `8443` → target group
  instance port `8080` → frontend Nginx container → `/api/` proxy to backend
  Spring Boot container.
- **Compute/data placement:** ALB in public subnets, EC2 Auto Scaling Group in
  private subnets, RDS MySQL in private DB subnets.
- **Stateless app tier:** EC2 instances remain immutable and disposable;
  persistent state lives in RDS and managed services, not local instance disk.

### 4. CI/CD and Release Flow

- **Infra pipeline:** `infra-plan.yml` validates PR-time infra changes;
  `infra-apply.yml` applies on `main` or manual dispatch.
- **Application pipeline:** `app-deploy.yml` builds backend/frontend images,
  tags with `${GITHUB_SHA}`, pushes to ECR, updates SSM release parameters, and
  triggers ASG instance refresh.
- **Rollout strategy:** Launch-before-terminate refresh settings preserve
  availability while rotating instances onto the new release.

### 5. State, Persistence, and Operational Data

- **Terraform state and locking:** S3 backend durability + lockfile semantics;
  explain why this prevents concurrent write corruption.
- **Primary data store:** RDS MySQL with encryption, backups, private network
  access, and security-group scoping from app tier only.
- **Runtime configuration state:** SSM Parameter Store keys (for release/image
  tags) coordinate deployment metadata across workflows and instances.

### 6. Secrets and Identity

- **No secrets in repo or workflow vars:** Sensitive values in Secrets Manager
  only; code and Terraform reference paths/ARNs rather than plaintext.
- **Identity model:** GitHub OIDC for CI roles, EC2 instance profile for app
  runtime AWS access, and minimal IAM permissions aligned to function.
- **Application security controls:** JWT-based auth, rate limiting, and strict
  logging hygiene (do not expose credentials, tokens, or sensitive payloads).

## Data Grounding

All specs must match this repository's source docs and code. Use:
`README.md`, `CLAUDE.md`, `docs/auxiliary/planning/PROJECT_OVERVIEW.md`,
`docs/auxiliary/planning/PRODUCT_REQUIREMENTS_DOCUMENT.md`,
`docs/auxiliary/planning/TECHNICAL_REQUIREMENTS_REFERENCE.md`,
`docs/auxiliary/planning/ENGINEERING_EXECUTION_BACKLOG.md`,
`docs/auxiliary/architecture/ARCHITECTURE.md`, and `infra/envs/prod/*.tf`.
Do not add or contradict details (ports, account model, state locking,
deployment sequence, IAM boundaries, or secrets handling) from those files.

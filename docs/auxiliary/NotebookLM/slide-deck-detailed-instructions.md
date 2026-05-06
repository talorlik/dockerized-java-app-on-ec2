# Slide Deck Instructions (Detailed)

Generate a **15-20 slide technical reference deck** for **Wiki.js on AWS EKS Auto Mode**. Self-contained for stakeholders reading without a presenter.

## Objective

Cover end-to-end architecture: Terraform layering, multi-account DNS, EKS Auto Mode, GitOps, state/persistence, and secrets/identity-grounded in this project's Markdown docs.

## Visual Theme

**"Knowledge-Cloud Industrial."** Neon blue/cyan AWS icons; translucent 3D EKS/GitOps elements; glowing security (shields, locks); dark slate backgrounds with subtle grid/data-flow accents.

## Per-Slide Structure

1. **Clear title** (one line).
2. **3-5 technical bullets** (high information density).
3. **One key insight** sentence ("so what" for this slide).

## Mandatory Categories (All Six)

### 1. Tiered Terraform Deployment

- **Nine layers**, order: 00-bootstrap → 01-dns-main → 10-network → 20-eks → 30-data-rds → 35-storage-s3-assets → 40-platform → 45-argocd → 50-app-wikijs. Each layer = standalone root, own backend state key; **no terraform_remote_state**.
- **Inter-layer contract:** AWS Systems Manager Parameter Store only; path pattern `/<prefix>/<region>/<env>/<layer-id>-<layer-name>/<key>`.
- **State:** S3 (from bootstrap), SSE-KMS, versioning, public access block, **use_lockfile = true** (S3 native lockfile, no DynamoDB). Teardown: reverse order (50 → … → 00).

### 2. Multi-Account Security and DNS

- **Deployment account:** Terraform runs here; EKS, RDS, S3. **Domain account:** Route 53 hosted zone. **Roles:** deployment_account_role_arn (GitHub Actions/Terraform); domain_account_role_arn (01-dns-main only, creates DNS role); **dns_assume_role_arn** (created by 01-dns-main, trust = deployment role only; layer 50 assumes it for Route 53 A record).
- 01-dns-main publishes `dns_role_arn` to Parameter Store; layer 50 reads it (no CI pass-through). **Insight:** DNS scoped to one hosted zone; no broad domain-account access.

### 3. EKS Auto Mode, Ingress, ALB

- **EKS Auto Mode** (managed compute). ALB created by Kubernetes Ingress controller after Argo CD syncs Wiki.js Ingress.
- **Two-apply for layer 50:** First apply creates Argo CD Application and SecretProviderClass; Route 53 A record and Parameter Store outputs (alb_dns_name, alb_hosted_zone_id, application_url) need ALB-often **second run** after Argo CD sync.
- Ingress/TLS: hostname from bootstrap, ACM cert (ARN from Parameter Store). ALB in public subnets; workloads in private; RDS in DB subnets. **Insight:** Ingress is source of truth for ALB; Terraform consumes ALB attributes only after they exist.

### 4. GitOps and Delivery Flow

- **Argo CD** in 45-argocd (Helm, argocd namespace); internal by default (ClusterIP); optional external UI via argocd_server_fqdn.
- **Layer 50:** Argo CD Application → `apps/wikijs` (Helm/Requarks Wiki.js), env value files (e.g. values/dev.yaml).
- **Flow:** Repo → GitHub Actions (OIDC, per-layer) for Terraform; Argo CD syncs apps/wikijs → Wiki.js + Ingress → EKS creates ALB → layer 50 (second apply) writes Route 53 and Parameter Store. **Insight:** IaC and workload delivery both repo-driven; Terraform owns cluster/wiring, Argo CD owns Wiki.js manifest lifecycle.

### 5. State and Persistence

- **Terraform state:** S3, key `env:/<workspace>/<layer>/terraform.tfstate`, workspace = `<region>-<env>`; use_lockfile = true.
- **Parameter Store:** Inter-layer values only; no raw secrets-ARNs/IDs; each layer publishes under its prefix; destroy removes prefix.
- **RDS PostgreSQL:** Port 5432; Multi-AZ, encryption, backups, deletion protection; DB subnets; master password in Secrets Manager (Terraform stores ARN only).
- **S3 assets (35):** SSE-KMS, versioning, block public access; Wiki.js access via **IRSA** (ListBucket, object CRUD on prefix, KMS for key). **Insight:** State/config encrypted; app data in RDS/S3 with strict network and IAM boundaries.

### 6. Secrets and Identity

- **No secrets in code, logs, or state.** Secrets Manager; Terraform/workflows reference ARNs only.
- **GitHub Actions:** OIDC → deployment_account_role_arn; no repo AWS secrets; role ARN = workflow_dispatch input; dynamic values from Parameter Store after assume.
- **EKS:** IRSA for Wiki.js (S3 from layer 35); Secrets Store CSI Driver + SecretProviderClass sync Secrets Manager into K8s secrets. RDS master password: secret ARN only; synced into cluster.
- **DNS:** Only dns_assume_role_arn assumed; trust restricted. **Insight:** Identity is role-based (OIDC, IRSA); secrets never in repo/state; cross-account least-privilege (Route 53 for one FQDN).

## Data Grounding

All specs must match this project's docs: `docs/architecture/architecture.md`, `docs/plan-and-requirements/` (PROJECT_PLAN, PRD_*), `docs/runbooks/` (setup, teardown, prerequisites), `docs/security/security-considerations.md`, README.md. Do not add or contradict details (ports, layer names, use_lockfile, two-apply, IRSA, etc.) from those files.

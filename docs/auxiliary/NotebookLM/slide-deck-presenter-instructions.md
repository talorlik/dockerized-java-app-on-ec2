# Slide Deck Instructions (Presenter Deck)

Generate a **10-slide minimalist presenter deck** for a **15-minute technical deep-dive** on **Wiki.js on AWS EKS Auto Mode**. All content must be grounded in this project's Markdown documentation.

## Objective

Walk the audience from problem and solution through the "golden path" deployment, EKS Auto Mode and ingress, cross-account DNS security, GitOps and resilience, and end-state-emphasizing **why** decisions were made, not just what was built.

## Visual Theme

**Futuristic Minimalist:** Black/dark slate backgrounds; neon blue/cyan or gold accents. Abstract visuals (clusters, keys, network flows). Minimal text per slide; visuals support the speaker.

## Per-Slide Requirements

1. **Visual Focus** - One core diagram or concept.
2. **Minimalist Text** - ≥5 short bullets (scannable).
3. **Speaker Script** - 2-3 sentences the presenter can say aloud.

## Mandatory Categories (~10 Slides)

**1. Problem & Solution** - Need: reliable, secure, scalable internal knowledge platform with full automation and observability. Solution: Wiki.js on AWS via Terraform (layered IaC), EKS Auto Mode, RDS PostgreSQL, S3, Argo CD (GitOps), strict secrets/identity. *Why* Wiki.js + EKS + full IaC.

**2. Golden Path Deployment** - Order: 00-bootstrap → 01-dns-main → 10-network → 20-eks → 30-data-rds → 35-storage-s3-assets → 40-platform → 45-argocd → 50-app-wikijs. Each layer = standalone Terraform root, own state; **Parameter Store only** for inter-layer contract (no `terraform_remote_state`). Teardown = reverse order with typed confirmation. *Why* layers and Parameter Store: clear dependencies, isolated state, safe teardown.

**3. EKS Auto Mode & Ingress** - EKS Auto Mode (managed compute). ALB created by Kubernetes Ingress after Argo CD syncs; no separate Load Balancer Controller. **Two-apply for layer 50:** first apply creates Argo CD Application and SecretProviderClass; Route 53 A record and Parameter Store outputs appear after ALB exists-often requires second provision run. *Why* EKS Auto Mode and accepting two-apply (Ingress as source of truth for ALB).

**4. Cross-Account DNS (Trust & Least Privilege)** - Deployment account (Terraform, EKS, RDS, S3) vs domain account (Route 53). Three roles: deployment_account_role_arn (GitHub Actions/Terraform); domain_account_role_arn (01-dns-main only, creates DNS role); dns_assume_role_arn (in domain account, trust policy allows only deployment_account_role_arn). Layer 50 assumes dns_assume_role_arn to create/update/delete only the Route 53 A record for Wiki.js FQDN. *Why* least privilege and "confused deputy" prevention.

**5. GitOps & Resilience** - Argo CD in 45-argocd; layer 50 creates Application for `apps/wikijs` (Helm). Flow: Repo → GitHub Actions (OIDC) → Terraform; Argo CD syncs `apps/wikijs` → Ingress → EKS creates ALB → layer 50 (second apply) writes Route 53. Resilience: Parameter Store (no remote state); Secrets Manager (no secrets in code/state); IRSA for workload identity. *Why* GitOps + Parameter Store + secrets/IRSA: repo as source of truth, minimal blast radius.

**6. Conclusion - End-State & Ops** - End-state: Wiki.js at FQDN over HTTPS (ACM); RDS + S3 (SSE-KMS, IRSA). Argo CD admin in Secrets Manager (ARN in Parameter Store). Teardown: 50 → … → 00 with confirmation; RDS deletion protection may need disabling first. *Why* "done" looks like this; how to teardown safely.

## Narrative Focus (Why)

- **Layers + Parameter Store:** Clear order, isolated state, no remote-state coupling, safe teardown.
- **EKS Auto Mode + two-apply:** Ingress-driven ALB, fewer moving parts.
- **Cross-account DNS role:** Only deployment role can assume DNS role; scope = one hosted zone.
- **GitOps + Secrets Manager + IRSA:** Repo as source of truth; no secrets in code/state; workload identity.
- **VPC endpoints:** Less NAT, better security/cost for private subnets.

## Data Grounding

**All content must come from this project's docs.** Source of truth: `docs/architecture/architecture.md`; `docs/plan-and-requirements/PROJECT_PLAN.md` and PRDs (PRD_00-bootstrap through PRD_50-app-wikijs); `docs/runbooks/setup.md`, `teardown.md`, `prerequisites.md`; `docs/security/security-considerations.md`; `README.md`. Do not add or contradict details from these documents.

**Important:** Base the entire deck on this documentation. Slide count, categories, and narrative must align with the Wiki.js-on-EKS architecture, deployment order, cross-account DNS model, and operational procedures in the cited files.

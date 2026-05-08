# CREATE AN AWS ARCHITECTURE DIAGRAM - DOCKERIZED JAVA APP ON EC2

Use this document as the prompt when creating an architectural diagram for this
project. The result must look like a professional AWS architecture diagram
produced by an AWS Solution Architect: clear boundaries, AWS-style components
and icons, labeled data and control flows, and consistent tier grouping.

## SCENARIO

Single architecture diagram for a project that deploys a **Dockerized Java
application** on **AWS** using **Terraform** as IaC (bootstrap + prod layers)
and **AWS Systems Manager Parameter Store** for release pointers and selected
non-secret configuration. The diagram must reflect all layers and runtime
components:

- **00-bootstrap**: Terraform state bucket (encryption, versioning,
  lockfile-based state locking)
- **01-domain-account-dns**: DNS IAM role in the domain account (assumable by
  deployment role for Route 53 changes)
- **10-network**: **VPC** for networking - subnets (public/private app/private
  DB), security groups, VPC endpoints, Internet Gateway, NAT Gateway, route
  tables
- **20-data-rds**: **Amazon RDS MySQL** as the shared application database
  (private DB subnets, production Multi-AZ posture, managed secrets)
- **30-images-and-release**: **Amazon ECR** repositories and release metadata
  in **SSM Parameter Store** (`backend-image-tag`, `frontend-image-tag`,
  `release-id`)
- **40-runtime-ec2-asg**: **EC2 Launch Template + Auto Scaling Group** in
  private app subnets, running **Docker Compose** workloads
- **50-edge-routing**: **ALB** listener on `443` with ACM TLS, Route 53
  alias for `java.talorlik.com`
- **60-observability-and-security**: CloudWatch metrics/logs/alarms, ALB access
  logs, WAFv2 at ALB, IAM/Secrets Manager controls

CI/CD: **GitHub Actions (OIDC)** runs validation, Terraform workflows, image
build + push, release pointer update, and ASG instance refresh. No long-lived
AWS keys.

## ACCOUNT MODEL (MUST APPEAR)

- **Domain account**: Owns the Route 53 hosted zone for `talorlik.com`.
  Contains IAM role(s) used for cross-account DNS changes.
- **Deployment account**: Hosts VPC, ALB, WAF, ASG/EC2, RDS, ECR, Secrets
  Manager, Parameter Store, CloudWatch, SES, and ACM certificate.

Show **Domain account** and **Deployment account** as top-level boundaries.

## PREREQUISITES (PRE-EXISTING ELEMENTS - MUST APPEAR)

These elements exist **before** Terraform provisioning and are normally shown
on AWS architecture diagrams. Include them explicitly:

- **Registered domain** - Base domain `talorlik.com`, either in Route 53 or an
  external registrar, used for `java.talorlik.com`.
- **Route 53 public hosted zone** - In the **domain account**. Used for DNS
  resolution and ALB alias record(s). If domain is external, show **DNS
  delegation** (NS records at registrar to Route 53 name servers).
- **ACM certificate** - In the **deployment account**, same region as ALB.
  Used for TLS on ALB listener `443`; validated through DNS record(s) in the
  hosted zone.
- **GitHub OIDC provider** - In deployment account; allows GitHub Actions to
  assume IAM role without long-lived credentials.
- **IAM role for GitHub Actions (deployment account)** - e.g. `github-role`;
  trusted by OIDC provider; used by CI/CD and Terraform.
- **IAM role in domain account** - cross-account Route 53 management role
  assumed from deployment account when workflows need to update DNS.

## COMPONENTS TO INCLUDE

Group components logically; use **AWS icons** for AWS resources and
**container/app icons** where appropriate for workload components.

### 1) CI/CD and identity

- GitHub (repository + GitHub Actions workflows)
- GitHub OIDC provider
- IAM role for GitHub Actions (OIDC), e.g. `github-role`
- Terraform workflows (`infra-plan`, `infra-apply`)
- Application deployment workflow (`app-deploy`) building/pushing images and
  triggering ASG refresh

### 2) DNS and TLS (cross-account)

Include the prerequisite elements listed above (domain, hosted zone, ACM cert).
In addition:

**Domain account:**

- Registered domain and hosted zone
- Cross-account Route 53 role (assumed from deployment account workflows)
- A/ALIAS record: `java.talorlik.com` -> ALB

**Deployment account:**

- ACM certificate for ALB listener on `443`
- IAM role chain from GitHub Actions to domain DNS role

### 3) Network (deployment account)

- VPC
- Public subnets (>=2 AZs): ALB, Internet Gateway, NAT Gateway
- Private app subnets (>=2 AZs): EC2 Auto Scaling Group instances
- Private DB subnets (>=2 AZs): RDS MySQL
- Route tables (public, private app, private DB)
- Security groups:
  - ALB SG: inbound `443` from internet, outbound to app on `8080`
  - App SG: inbound `8080` from ALB SG, outbound to RDS and AWS APIs
  - RDS SG: inbound `3306` from App SG only
- VPC endpoints (where modeled): S3 (gateway), ECR API/DKR, SSM/Secrets
  Manager/CloudWatch Logs (interface)

### 4) Compute and application runtime (deployment account)

- EC2 Launch Template (IMDSv2 enforced, encrypted root EBS)
- EC2 Auto Scaling Group in private app subnets
- Docker Compose runtime per instance:
  - Frontend container: Nginx static UI (host `8080:80`)
  - Backend container: Spring Boot API (internal `8080`)
  - Optional CloudWatch Agent
- Nginx reverse proxy behavior for `/api` to backend container

### 5) Data and messaging (deployment account)

- RDS MySQL (private, encrypted, backups, production Multi-AZ posture)
- Amazon SES for transactional verification email sending
- (Optional if shown) S3 for ALB access logs and/or artifacts

### 6) Configuration and secrets (deployment account)

- **Parameter Store**: release metadata keys and selected non-secret runtime
  values.
- **Secrets Manager**: DB and app secrets, admin bootstrap secret, JWT secret.
- IAM instance profile/permissions for EC2 runtime secret/config reads.

## CONNECTIONS TO SHOW

Use arrows and label important flows (protocol/port or mechanism).

### User traffic

- Users -> Route 53 -> ALB (`HTTPS 443`, TLS via ACM) -> EC2 instances
  (`HTTP 8080`) -> Nginx frontend and backend API

### Application dependencies

- Backend container -> RDS MySQL (`3306`)
- Backend container -> Secrets Manager (retrieve secrets)
- Backend container -> SES (send verification emails)
- EC2 runtime -> ECR (image pull)
- EC2 runtime -> Parameter Store (read release pointers/config)

### CI/CD and control plane

- GitHub Actions -> AWS via OIDC -> assume deployment role -> Terraform/app
  deploy workflows
- Terraform/app workflow -> assume domain DNS role -> update Route 53 records
- App deploy workflow -> build images -> push to ECR -> update release
  parameters -> start ASG Instance Refresh

### Observability and protection

- EC2/app logs + metrics -> CloudWatch Logs/Metrics
- ALB access logs -> S3 (if enabled)
- Internet traffic -> WAFv2 -> ALB

Keep **control-plane** flows (GitHub, Terraform, deploy automation) visually
distinct from **data-plane** flows (user traffic, API/DB traffic).

## LAYOUT

- Top-level split: **Domain account** | **Deployment account**.
- Top row: **Users**, **GitHub Actions**.
- DNS/TLS near top: Route 53 hosted zone (domain account), ACM + ALB
  (deployment account), cross-account DNS role link.
- Center: deployment account **VPC** with:
  - Public subnets: ALB, IGW, NAT
  - Private app subnets: EC2 ASG and Docker workloads
  - Private DB subnets: RDS MySQL
- Right or bottom-right: **Secrets and configuration** (Secrets Manager,
  Parameter Store, IAM).
- Bottom: **Data/ops plane** (RDS, CloudWatch, S3 logs, SES).

### Tier colors (consistent with AWS-style diagrams)

- **Edge (DNS/ALB/WAF):** light blue
- **Compute platform (EC2/ASG/containers):** light green
- **Data (RDS/S3):** light orange
- **Security/config (IAM, Secrets Manager, Parameter Store, KMS):**
  light purple
- **CI/CD (GitHub, Terraform, deploy workflows):** light gray

## DIAGRAM REQUIREMENTS

- Use **AWS icons** for all AWS services and clear app/workload icons for
  frontend/backend containers.
- Use this project's concrete names where applicable:
  - `java.talorlik.com`
  - `github-role`
  - Route 53 cross-account DNS role
  - ALB `443` -> EC2 `8080`
- Label key connections (e.g. `HTTPS 443`, `HTTP 8080`, `MySQL 3306`,
  `OIDC`, `AssumeRole`).
- Do **not** include implementation-only details such as full Terraform state
  internals, exact SSM path format templates, or workflow input minutiae.
- Layout and grouping above are prescriptive; the diagram should be
  implementable from this prompt and must adhere to the project architecture in
  `docs/auxiliary/architecture/ARCHITECTURE.md`.

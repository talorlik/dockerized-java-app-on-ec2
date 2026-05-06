# DOCKERIZED JAVA APP ON AWS EC2 - ARCHITECTURE DIAGRAM GENERATION AGENT

## ROLE

You are a diagram-generation agent for this repository. Your job is to
generate accurate, consistent, and automation-friendly architecture diagrams
for deploying the Dockerized Java app on AWS using:

- AWS VPC for networking
- EC2 Auto Scaling Group and Launch Template for compute
- Amazon RDS for MySQL as the external database
- Amazon ECR for backend/frontend image storage
- AWS Secrets Manager for all secrets
- AWS Systems Manager Parameter Store for release metadata and runtime values
- GitHub Actions for CI/CD and Terraform execution
- Terraform as the IaC source of truth
- Amazon SES for email delivery
- AWS WAFv2 for edge protection at the ALB

You must produce:

- A Python script at
  `docs/auxiliary/architecture-diagrams/generated-python.py` that generates
  diagrams using the `diagrams` Python library and Graphviz.
- Rendered diagram artifacts under
  `docs/auxiliary/architecture-diagrams/diagrams/` in these formats: `.png`,
  `.dot`, `.drawio`.

**Single unified diagram.** The deliverable is **one architecture diagram for the entire project** (or a small set of views-e.g. runtime, network, delivery-each of which is a single diagram spanning the whole system). The Terraform **layers are for data collection only**: run plan per layer, collect `tfplan.json` from each layer, then **parse and merge** all layer outputs into one model and render a **single, unified diagram**. Do not produce one diagram per layer.

Your diagrams must reflect the repository's Terraform deployment model
(`infra/bootstrap` and `infra/envs/prod`) and the runtime topology inside AWS.

## FILE STRUCTURE

```bash
docs/
    architecture-diagrams/
        diagrams/
            *.png                         # Will be created upon execution
            *.dot                         # Will be created upon execution
            *.drawio                      # Will be created upon execution
        generated-python.py               # Will be created upon execution
        SETUP.md
        AGENT.md
        INSTRUCTIONS.md
```

## DIAGRAM GENERATION WORKFLOW

1. READ INPUTS
   - Read `docs/auxiliary/architecture/ARCHITECTURE.md`,
     `docs/auxiliary/planning/PROJECT_OVERVIEW.md`, and the ADR files under
     `docs/auxiliary/adr/`.
   - Identify the Terraform roots and responsibilities:
     `infra/bootstrap` (state foundation) and `infra/envs/prod` (runtime
     resources).

2. DERIVE THE DIAGRAM SET
   - Produce **one unified diagram** (or a small set of views) for the **entire project**. Merge data from all layers into a single model; do not output one diagram per layer. The diagram set should cover, at minimum:
     - HIGH-LEVEL RUNTIME TOPOLOGY: Users -> Route 53 -> ALB `:8443` ->
      EC2 ASG (Nginx + Spring Boot containers) -> RDS MySQL, Secrets Manager,
      ECR, Parameter Store, and SES.
     - NETWORK TOPOLOGY: VPC, subnets (public/private app/private db), NAT,
       internet egress, and traffic direction.
     - DELIVERY AND CONTROL PLANE: GitHub Actions (OIDC role) -> Terraform and
       app deploy workflows -> ECR push -> ASG instance refresh.
     - DEPENDENCY VIEW: Terraform roots and major resource dependencies across
       network, security, compute, data, and delivery.

3. GENERATE `generated-python.py`
   - **Input:** Plan/state JSON from `infra/bootstrap` and `infra/envs/prod`.
     Parse and merge into one model.
   - **Output:** **One unified diagram** for the entire project (or one
     function per view, such as runtime and network, where each view is a
     single diagram spanning the whole system). Each diagram produces:
     - `diagrams/<name>.dot` (Graphviz source)
     - `diagrams/<name>.png` (rendered image)
   - Ensure `generated-python.py` writes output files to
     `docs/auxiliary/architecture-diagrams/diagrams/`.

4. CONVERT DOT TO DRAW.IO
   - After generating `.dot` files, convert each to `.drawio`.
   - Use a deterministic conversion approach (CLI tool or script) so regeneration is repeatable.

5. VALIDATE OUTPUTS
   - Verify each diagram:
     - Uses correct AWS node classes and labels.
     - Uses tier coloring and group clusters consistently.
     - Avoids secret values and sensitive strings in labels.
     - Remains readable (avoid excessive node density by splitting into multiple diagrams/views).

## PARSING INFRASTRUCTURE-AS-CODE

### TERRAFORM PARSING

Use Terraform outputs (plan/state JSON) as the primary parsing source. Avoid
parsing raw `.tf` files as the only source because module expansion and
computed dependencies are not visible.

1. COLLECT TERRAFORM JSON (data collection only; used to build one unified
   diagram)

   Run these commands from the repository root. **Do not run
   `terraform apply` or `terraform destroy`.**

   **Bootstrap root (`infra/bootstrap`)**

   ```bash
   cd infra/bootstrap
   terraform init
   terraform validate
   terraform plan -out=tfplan
   terraform show -json tfplan > tfplan.bootstrap.json
   ```

   **Production root (`infra/envs/prod`)**

   ```bash
   cd infra/envs/prod
   terraform init
   terraform validate
   terraform plan -var-file=terraform.tfvars -out=tfplan
   terraform show -json tfplan > tfplan.prod.json
   ```

   If plan is unavailable but state is authoritative, use:

   ```bash
   terraform show -json > state.json
   ```

   Use these JSON files as the only parsing inputs.

2. EXTRACT RESOURCES AND DEPENDENCIES
   - Parse `resource_changes` and `planned_values` from both plan/state JSON
     files into a **single merged model** (one graph or dataset) that feeds
     the unified diagram.
   - Per root: identify resources and key attributes (names, ARNs, IDs).
   - Derive edges from:
     - `depends_on` (explicit)
     - implicit dependencies via referenced attributes (when visible in JSON)
   - Collapse low-signal resources (tags, associations) unless they materially change topology.

3. MAP TERRAFORM TO DIAGRAM NODES
   - Use a resource-type mapping table in code (dictionary) to map Terraform resource types or module outputs to AWS diagram nodes.
   - Prefer mapping at the "service" level (ALB, ASG/EC2, RDS, ECR, Secrets
     Manager, Parameter Store, SES, WAF) rather than every underlying resource.

4. MODEL CROSS-ROOT CONTRACTS
   - Treat `infra/bootstrap` outputs as foundational inputs to
     `infra/envs/prod`.
   - Treat Parameter Store as the runtime value exchange point for release
     metadata and non-secret configuration.
   - In the DEPENDENCY VIEW:
     - Create one node per Terraform root.
     - Create a Parameter Store node as an exchange point where applicable.
     - Draw directed edges:
       - root -> Parameter Store (publishes)
       - Parameter Store -> runtime resources (consumes)
   - Do not model secret values as data flow edges. Model Secrets Manager as a
     shared dependency.

## COLOR CODING FOR TIERS

Use cluster background colors to make diagrams scannable. Apply tier colors consistently across all diagrams.

### TIERS AND COLORS

- EDGE AND DNS (Route 53, Hosted Zone, ACM) - `#E3F2FD`
- INGRESS AND LOAD BALANCING (ALB, listeners, target groups) - `#E8EAF6`
- NETWORKING (VPC, subnets, route tables, NAT, IGW, endpoints) - `#E0F7FA`
- ORCHESTRATION AND COMPUTE (ASG, EC2 instances, Docker runtime) - `#E8F5E9`
- DELIVERY AND RELEASE (GitHub Actions, ECR, instance refresh) - `#F3E5F5`
- DATA (RDS MySQL, backups) - `#FFF3E0`
- STORAGE (EBS and S3 where applicable) - `#FFF8E1`
- SECURITY AND CONFIG (IAM roles, KMS, Secrets Manager, Parameter Store) - `#FFEBEE`
- OBSERVABILITY (CloudWatch, logs/metrics endpoints) - `#ECEFF1`

### APPLY TO GROUP CLUSTERS

Use clusters to group by ACCOUNT, REGION, VPC, and SUBNET-TIER. Expand groupings beyond "cluster" to fit this project:

- ACCOUNT GROUPING
  - `DOMAIN ACCOUNT` (Hosted Zone authority)
  - `DEPLOYMENT ACCOUNT` (ALB, ASG, EC2, RDS, ECR, Secrets Manager,
    Parameter Store, SES, WAF)

- REGION GROUPING
  - `REGION: <aws-region>` (all resources in the deployment region)

- VPC GROUPING
  - `VPC: <vpc-name>`
    - `PUBLIC SUBNETS` (ALB, IGW route)
    - `PRIVATE APP SUBNETS` (ASG EC2 instances)
    - `DB SUBNETS` (RDS subnet group)

- COMPUTE GROUPING
  - `AUTO SCALING GROUP: <asg-name>`
    - `EC2 INSTANCE: <instance-id or launch-template-derived>`
    - `DOCKER CONTAINERS: frontend-nginx, backend-spring-boot`

- CONTRACT GROUPING
  - `PARAMETER STORE CONTRACT` (cross-layer non-secret values)
  - `SECRETS MANAGER` (credentials, tokens, private keys)

In `generated-python.py`, implement a single palette dict and apply it uniformly:

```python
TIER_COLORS = {
    "EDGE_DNS": "#E3F2FD",
    "INGRESS": "#E8EAF6",
    "NETWORK": "#E0F7FA",
    "COMPUTE": "#E8F5E9",
    "DELIVERY_RELEASE": "#F3E5F5",
    "DATA": "#FFF3E0",
    "STORAGE": "#FFF8E1",
    "SECURITY_CONFIG": "#FFEBEE",
    "OBSERVABILITY": "#ECEFF1",
}

def cluster_attrs(bg: str) -> dict:
    return {"style": "filled", "color": bg}
```

## COMMON AWS ICON IMPORTS

Use AWS node classes from the `diagrams` library as the only source of icon imports. Validate node class names against the library's official node reference before emitting code.

Minimal import set for this project:

```python
from diagrams import Cluster, Diagram, Edge

# EDGE / DNS / CERTS
from diagrams.aws.network import Route53, Route53HostedZone
from diagrams.aws.security import CertificateManager

# NETWORKING
from diagrams.aws.network import (
    VPC,
    InternetGateway,
    NATGateway,
    PublicSubnet,
    PrivateSubnet,
    RouteTable,
    VPCRouter,
    VPCGatewayEndpoint,
    VPCInterfaceEndpoint,
)

# INGRESS
from diagrams.aws.network import ELBApplicationLoadBalancer

# COMPUTE / ORCHESTRATION
from diagrams.aws.compute import AutoScaling, EC2

# DATA
from diagrams.aws.database import RDS

# STORAGE
from diagrams.aws.storage import EBS

# SECURITY / CONFIG
from diagrams.aws.security import IAMRole, KMS, SecretsManager
from diagrams.aws.managementtools import SystemsManagerParameterStore

# RELEASE / DELIVERY
from diagrams.aws.devtools import ECR

# OBSERVABILITY (OPTIONAL, WHEN USED IN DIAGRAMS)
from diagrams.aws.management import Cloudwatch
```

If a required service has no AWS node class in the library, use a
`diagrams.generic` node for that specific element only and label it
explicitly (for example: "SPRING BOOT API CONTAINER").

## TROUBLESHOOTING

- GRAPHVIZ NOT FOUND OR DOT RENDER FAILS
  - Ensure Graphviz is installed and `dot` is on PATH.
  - Verify the script can write to
    `docs/auxiliary/architecture-diagrams/diagrams/`.

- IMPORT ERRORS (MISSING NODE CLASSES)
  - Validate the exact node class name and module path against the diagrams node reference.
  - Prefer alias classes when available and keep imports minimal.

- DRAW.IO CONVERSION FAILS
  - Ensure the converter tool is installed and supports the generated DOT syntax.
  - Keep DOT output deterministic (no random IDs, stable node keys) to reduce diff noise.

- DIAGRAM TOO DENSE / UNREADABLE
  - Split into multiple views.
  - Collapse low-level resources into service-level nodes.
  - Prefer one VPC-level diagram and one workload-level diagram over a single monolith.

## OUTPUT FILES

All outputs must be written under
`docs/auxiliary/architecture-diagrams/diagrams/`.

For each diagram `<name>`:

- `docs/auxiliary/architecture-diagrams/diagrams/<name>.dot`
- `docs/auxiliary/architecture-diagrams/diagrams/<name>.png`
- `docs/auxiliary/architecture-diagrams/diagrams/<name>.drawio`

`docs/auxiliary/architecture-diagrams/generated-python.py` must be the only
generated source file.

## KEY PRINCIPALS

- SOURCE OF TRUTH
  - Terraform plan/state JSON is authoritative for infrastructure topology.
  - Repository architecture/PRD docs are authoritative for intent and non-IaC
    runtime components.

- ROOT ISOLATION
  - Diagrams must reflect the repository's Terraform root model and avoid
    implying unnecessary coupling.
  - Cross-root linkage should be shown through explicit Terraform references
    and runtime integrations (Parameter Store for non-secret values,
    Secrets Manager for secrets).

- NO SECRETS IN DIAGRAMS
  - Never print secret values, tokens, passwords, private keys, or full connection strings in labels.

- REPRODUCIBILITY
  - Output is deterministic: stable ordering, stable naming, stable file paths.
  - Regeneration should produce minimal diffs when topology does not change.

- READABILITY OVER COMPLETENESS
  - Prefer clear service-level diagrams over exhaustive node graphs.
  - Only include low-level resources when they change the threat model or traffic path.

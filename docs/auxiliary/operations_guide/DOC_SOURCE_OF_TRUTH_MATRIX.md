# Documentation Source Of Truth Matrix

This matrix maps operational and architecture documentation to the canonical
implementation files in this repository.

Use it as a fast drift-prevention checklist before changing docs or workflows.

## How To Use

1. Identify the topic you are editing.
2. Validate facts against the "Canonical Source Files" column first.
3. Update every listed documentation target for that row.
4. Run a final grep pass for common drift tokens (`8443`, trigger semantics,
   parameter types, endpoint paths).

## Workflow And Delivery Matrix

| Topic | Canonical Source Files | Documentation Targets |
| ---- | ---- | ---- |
| CI gate behavior | `.github/workflows/ci.yml` | `README.md`, `docs/index.html`, `docs/auxiliary/planning/PROJECT_OVERVIEW.md`, `docs/auxiliary/planning/PRODUCT_REQUIREMENTS_DOCUMENT.md`, `docs/auxiliary/planning/TECHNICAL_REQUIREMENTS_REFERENCE.md`, `docs/auxiliary/planning/ENGINEERING_EXECUTION_BACKLOG.md`, `docs/auxiliary/operations_guide/03-deployment.md` |
| Infra plan trigger and outputs | `.github/workflows/infra-plan.yml` | `README.md`, `docs/index.html`, `docs/auxiliary/planning/PROJECT_OVERVIEW.md`, `docs/auxiliary/planning/PRODUCT_REQUIREMENTS_DOCUMENT.md`, `docs/auxiliary/planning/TECHNICAL_REQUIREMENTS_REFERENCE.md`, `docs/auxiliary/planning/ENGINEERING_EXECUTION_BACKLOG.md`, `docs/auxiliary/operations_guide/03-deployment.md` |
| Infra apply behavior | `.github/workflows/infra-apply.yml` | `README.md`, `docs/index.html`, `docs/auxiliary/planning/PROJECT_OVERVIEW.md`, `docs/auxiliary/operations_guide/03-deployment.md`, `docs/auxiliary/operations_guide/04-operations.md`, `docs/auxiliary/adr/0005-secret-rotation.md`, `docs/auxiliary/adr/0007-dev-environment-cycle-defaults.md` |
| App deploy behavior | `.github/workflows/app-deploy.yml` | `README.md`, `docs/index.html`, `docs/auxiliary/planning/PROJECT_OVERVIEW.md`, `docs/auxiliary/operations_guide/03-deployment.md`, `docs/auxiliary/operations_guide/04-operations.md`, `docs/auxiliary/architecture/ARCHITECTURE.md` |
| App destroy behavior | `.github/workflows/app-destroy.yml` | `README.md`, `docs/index.html`, `docs/auxiliary/operations_guide/03-deployment.md`, `docs/auxiliary/operations_guide/04-operations.md` |
| Infra destroy behavior | `.github/workflows/infra-destroy.yml` | `README.md`, `docs/index.html`, `docs/auxiliary/operations_guide/03-deployment.md`, `docs/auxiliary/operations_guide/04-operations.md`, `docs/auxiliary/adr/0007-dev-environment-cycle-defaults.md` |

## Runtime And Infra Matrix

| Topic | Canonical Source Files | Documentation Targets |
| ---- | ---- | ---- |
| ALB listeners, ports, health checks | `infra/envs/prod/alb.tf`, `infra/envs/prod/locals.tf`, `infra/envs/prod/security.tf` | `README.md`, `docs/index.html`, `docs/auxiliary/architecture/ARCHITECTURE.md`, `docs/auxiliary/planning/PROJECT_OVERVIEW.md`, `docs/auxiliary/planning/PRODUCT_REQUIREMENTS_DOCUMENT.md`, `docs/auxiliary/planning/TECHNICAL_REQUIREMENTS_REFERENCE.md`, diagram docs and generated diagram artifacts |
| ASG refresh and scaling posture | `infra/envs/prod/asg.tf`, `.github/workflows/app-deploy.yml` | `README.md`, `docs/index.html`, `docs/auxiliary/planning/PROJECT_OVERVIEW.md`, `docs/auxiliary/operations_guide/03-deployment.md`, `docs/auxiliary/operations_guide/04-operations.md` |
| RDS engine and upgrade posture | `infra/envs/prod/rds.tf`, `app/docker/docker-compose.local.yml`, `app/backend/src/main/resources/application-test.yml`, `app/backend/src/test/java/com/talorlik/javaapp/integration/MigrationsIT.java` | `README.md`, `docs/index.html`, `docs/auxiliary/adr/0008-mysql-8-4-upgrade.md`, `docs/auxiliary/operations_guide/runbooks/2026-05-08_appuser_auth_plugin_conversion.md`, planning docs |
| Compose runtime contract | `app/docker/docker-compose.prod.yml`, `app/frontend/nginx.conf`, `infra/envs/prod/templates/user_data.sh.tpl` | `README.md`, `docs/index.html`, `docs/auxiliary/architecture/ARCHITECTURE.md`, `docs/auxiliary/planning/PROJECT_OVERVIEW.md`, `docs/auxiliary/operations_guide/03-deployment.md` |
| Secret namespace and IAM access | `infra/envs/prod/secrets.tf`, `infra/envs/prod/iam.tf`, `.github/scripts/purge_pending_secrets.sh` | `README.md`, `docs/index.html`, `docs/auxiliary/operations_guide/04-operations.md`, `docs/auxiliary/operations_guide/05-security-model.md`, ADRs 0005 and 0007 |
| Terraform version constraints | `infra/bootstrap/versions.tf`, `infra/envs/prod/versions.tf` | `README.md`, `docs/auxiliary/operations_guide/00-prerequisites.md`, planning docs |

## Documentation Index Completeness Matrix

| Index Surface | Must Reference |
| ---- | ---- |
| `docs/index.html` | Core planning docs, operations guides 00-05, ADR 0001-0008, active runbooks (including MySQL auth-plugin conversion), architecture/diagram guidance |
| `README.md` | End-to-end deploy and destroy flow, trigger semantics, public endpoint, core runtime topology, links to operations/security docs |

## High-Risk Drift Tokens

Search these tokens during every docs PR:

- `8443`
- `:8443`
- `Merge to main`
- `pull request touching infra/**`
- `--type String` (for release SSM params)
- `/health` versus `/actuator/health`
- `~> 1.7` (when actual Terraform constraint differs)

## Quick Drift Check Commands

Run from repo root:

```bash
rg "8443|:8443|Merge to `main`|pull request touching `infra/\\*\\*`|--type String|/health|~> 1\\.7" README.md docs
rg "workflow_dispatch|workflow_call|pull_request|push:" .github/workflows
rg "alb_https_port|listeners|health_check|compose-object|SecureString" infra/envs/prod .github/workflows app/docker
```

Automated guard (same assertions, CI-safe):

```bash
chmod +x .github/scripts/docs_drift_check.sh
.github/scripts/docs_drift_check.sh
```

## Ownership Suggestion

- When workflows change: update docs in the same PR.
- When infra runtime ports/endpoints change: update architecture and planning
  docs in the same PR.
- When release metadata or secret handling changes: update operations and
  security docs in the same PR.

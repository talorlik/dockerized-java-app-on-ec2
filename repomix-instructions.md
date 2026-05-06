# Repomix Instructions for this repository

## Overview

You are an expert AWS DevOps and Platform Architect. This document is a packed
snapshot of this repository. Use the directory tree at the top as the
system-of-record for how components relate.

## Primary Goal

Build an accurate mental model of the end-to-end platform architecture,
application runtime, infrastructure-as-code, and deployment workflow, focusing
on:

- The intended architecture described in
  `docs/auxiliary/architecture/ARCHITECTURE.md` and how it maps to Terraform
  under `infra/`.
- The canonical planning and requirements set under `docs/auxiliary/planning/`,
  especially:

  - `PROJECT_OVERVIEW.md` as the primary architecture/product specification
  - `PRODUCT_REQUIREMENTS_DOCUMENT.md` and
    `TECHNICAL_REQUIREMENTS_REFERENCE.md` as supporting constraints
  - `ENGINEERING_EXECUTION_BACKLOG.md` for implementation sequencing
  - `docs/auxiliary/adr/` and `docs/auxiliary/operations_guide/` as decision
    and operations context
- Terraform parsing and representation, especially:

  - How bootstrap state (`infra/bootstrap/`) and production resources
    (`infra/envs/prod/`) are separated
  - How network, security, data, runtime, DNS, observability, and release
    concerns are modeled across `*.tf` files
- Automation hooks:

  - GitHub Actions workflows under `.github/workflows/` for CI quality gates,
    infra plan/apply/destroy, and app deploy/destroy
  - How image build/push, SSM release metadata, and ASG refresh form the
    release pipeline
- Security and correctness invariants:

  - No secrets in committed sources, packed outputs, logs, or generated docs
  - Deterministic and auditable infra/app delivery from source-controlled inputs
  - Clear separation between source inputs (Terraform, app code, docs) and
    generated/runtime artifacts

## Extraction Instructions

1. Summarize the repository's purpose and end-to-end delivery model (inputs -
   processing - outputs) across application, infrastructure, and operations.
2. Identify all "sources of truth" files and precedence rules across
   `CLAUDE.md`, `docs/auxiliary/planning/PROJECT_OVERVIEW.md`,
   `docs/auxiliary/architecture/ARCHITECTURE.md`, ADRs, and workflow files.
3. Enumerate Terraform roots/modules parsed and list key resource graph
   relationships expected in production (VPC/subnets, ALB/ASG/EC2, RDS, IAM,
   ECR, Secrets Manager, SES, Route53, WAF, observability).
4. Trace execution flows for:

   - Local development path (Docker Compose, backend/frontend behavior, env
     assumptions, migration behavior)
   - CI/CD path (workflow triggers, quality gates, infra plans/applies, app
     deployment steps, release metadata, and rollout behavior)
5. List "gotchas" and invariants (path assumptions, idempotency, ordering
   stability, environment requirements, and common failure modes).

## Ignore Patterns

- Non-essential markdown boilerplate, badges, and screenshots.
- Generated and vendored outputs (`infra/envs/prod/.terraform/**`,
  `app/backend/target/**`, local caches), Terraform plan/state artifacts,
  `node_modules`, and Python virtual environments.

## Ambiguity Handling

When something is ambiguous, state the assumption explicitly and point to the
exact file/path that would confirm it. If two sources conflict, prefer
`docs/auxiliary/planning/PROJECT_OVERVIEW.md` for architecture intent and
`infra/envs/prod/*.tf` plus `.github/workflows/*.yml` for implemented behavior.

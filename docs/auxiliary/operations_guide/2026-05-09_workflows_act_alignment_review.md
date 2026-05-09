# 2026-05-09 - GitHub Actions / `act` Alignment Review

Scope: every file under `.github/workflows/`, `.actrc`, and the `act`
local-credentials surface.

Method: read every workflow line-by-line, cross-check every
`aws-actions/configure-aws-credentials@*` step for an `env.ACT` guard,
verify every `actions/upload-artifact` step is gated, audit every
`secrets.*` and `vars.*` reference for representation in the
`--secret-file` / `--var-file` surface, walk concurrency / triggers /
runner-image expectations, and compare against the canon enforced by
`.github/scripts/docs_drift_check.sh`.

Original pass (2026-05-09): no workflow files were modified. Three template
files were created (`.github/{env,secrets,vars}.local.example`).

Revision (2026-05-09, later): Findings 1 and 2 landed
(`if: ${{ env.ACT != 'true' }}` guards on the OIDC step in
`infra-plan.yml:26` and `app-destroy.yml:79`). A third gap, ECR docker login
under `act`, was discovered during a re-run and remediated in
`app-deploy.yml` (see Finding 10 below). A fourth, `AWS_PAGER` scope drift in
`infra-apply.yml`, was promoted to job level (see Finding 11 below).

---

## 1. Workflow inventory

| Workflow | Triggers | Jobs | Runners | OIDC step | Artifact step | act-compat verdict |
|---|---|---|---|---|---|---|
| `ci.yml` | `workflow_dispatch`, `workflow_call` | `docs-drift`, `backend`, `frontend`, `compose-smoke`, `iac-checks` | `ubuntu-latest` | none (no AWS API calls) | yes, `!env.ACT && always()` (correct) | aligned |
| `infra-plan.yml` | `workflow_dispatch` | `plan` | `ubuntu-latest` | unconditional (line 20) | yes, `!env.ACT` (correct) | misaligned (see Finding 1) |
| `infra-apply.yml` | `workflow_dispatch` | `apply` | `ubuntu-latest` | guarded `env.ACT != 'true'` (line 54) | none | aligned |
| `infra-destroy.yml` | `workflow_dispatch` | `destroy` | `ubuntu-latest` | guarded `env.ACT != 'true'` (line 96) | none | aligned |
| `app-deploy.yml` | `workflow_dispatch` | `build-test` (calls ci.yml), `deploy` | `ubuntu-latest` | guarded `env.ACT != 'true'` (line 56) | none | aligned (deploy job); `build-test` reuse of ci.yml inherits its act behavior |
| `app-destroy.yml` | `workflow_dispatch` | `destroy` | `ubuntu-latest` | unconditional (line 73) | none | misaligned (see Finding 2) |

Concurrency map (sanity): `ci-${{ github.ref }}` and `infra-plan-${{ github.ref }}` are per-ref with cancel-in-progress; `infra-apply`, `infra-destroy`, `app-deploy`, `app-destroy` are global, no cancel-in-progress. Consistent with the operational model. `act` ignores `concurrency:` blocks, so no compat impact.

---

## 2. Findings

### Finding 1 (high, RESOLVED 2026-05-09): `infra-plan.yml` runs OIDC unconditionally

Status: applied. `infra-plan.yml:26` now carries
`if: ${{ env.ACT != 'true' }}` on the
`aws-actions/configure-aws-credentials@v5.1.1` step.

Original analysis: `.github/workflows/infra-plan.yml:20-24` called
`aws-actions/configure-aws-credentials@v5.1.1` with `role-to-assume` and no
`if:` gate. Under `act`, this failed because no OIDC issuer is reachable, and
even if it succeeded it would have clobbered the static creds loaded from
`.github/env.local` via `.actrc`.

Other infra/app workflows use the pattern:

```yaml
- uses: aws-actions/configure-aws-credentials@61815dcd50bd041e203e49132bacad1fd04d2708 # v5.1.1
  if: ${{ env.ACT != 'true' }}
  with:
    role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
    aws-region: ${{ vars.AWS_REGION }}
    role-session-name: gha-...
```

Proposed diff (apply only after approval):

```diff
--- a/.github/workflows/infra-plan.yml
+++ b/.github/workflows/infra-plan.yml
@@ -18,6 +18,7 @@ jobs:
       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

       - uses: aws-actions/configure-aws-credentials@61815dcd50bd041e203e49132bacad1fd04d2708 # v5.1.1
+        if: ${{ env.ACT != 'true' }}
         with:
           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
           aws-region: ${{ vars.AWS_REGION }}
```

Severity: high. Without the guard, `act -W .github/workflows/infra-plan.yml` cannot execute end-to-end; the user has to comment out the step manually.

### Finding 2 (high, RESOLVED 2026-05-09): `app-destroy.yml` runs OIDC unconditionally

Status: applied. `app-destroy.yml:79` now carries
`if: ${{ env.ACT != 'true' }}` on the
`aws-actions/configure-aws-credentials@v5.1.1` step.

Original analysis: `.github/workflows/app-destroy.yml:73-77` had the same
defect. Same fix:

```diff
--- a/.github/workflows/app-destroy.yml
+++ b/.github/workflows/app-destroy.yml
@@ -71,6 +71,7 @@ jobs:
           aws --version

       - uses: aws-actions/configure-aws-credentials@61815dcd50bd041e203e49132bacad1fd04d2708 # v5.1.1
+        if: ${{ env.ACT != 'true' }}
         with:
           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
           aws-region: ${{ vars.AWS_REGION }}
```

Severity: high. Same operational impact as Finding 1.

### Finding 3 (medium): `.actrc` references credential files that had no committed templates

`.actrc:35-37` declares:

```text
--env-file .github/env.local
--secret-file .github/secrets.local
--var-file .github/vars.local
```

The `.local` files are gitignored. Until this pass, no `*.example` companions existed, so a fresh clone could not run `act` without reverse-engineering every `${{ secrets.* }}` and `${{ vars.* }}` reference across six workflows.

Resolved by creating:

- `.github/env.local.example`
- `.github/secrets.local.example`
- `.github/vars.local.example`

These cover every `${{ secrets.* }}` / `${{ vars.* }}` reference observed across workflows: `DEPLOYMENT_ROLE_ARN`, `DOMAIN_ROUTE53_ROLE_ARN`, `ACM_CERTIFICATE_ARN`, `AWS_REGION`, `DEPLOYMENT_ACCOUNT_ID`, `DOMAIN_ACCOUNT_ID`, `HOSTED_ZONE_ID`, plus the AWS SDK static-creds env (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`), `DOCKER_HOST`, `TESTCONTAINERS_RYUK_DISABLED`, and `AWS_PAGER`.

Onboarding is now a `cp` per file and a populate.

### Finding 4 (low): `infra-plan.yml` has no `Ensure AWS CLI present` step

The other infra and app workflows each carry an `Ensure AWS CLI present` step that installs `aws` when the runner image lacks it (the slim `act` images do; full-24.04 ships it). `infra-plan.yml` omits this step.

Functional impact: zero. `terraform plan` and the Terraform S3 backend talk to AWS through the Terraform AWS provider's embedded SDK; no shell-out to `aws` happens in the plan path. The S3 backend init (line 33) and the ACM cross-account assume (passed via `TF_VAR_*`) both flow through the provider, not the CLI.

Recommendation: leave as-is unless a future plan step grows an `aws` shell-out. If added for symmetry, it adds ~15 s of cold install time on slim act images but is otherwise free.

### Finding 5 (informational): trigger model is intentionally manual-dispatch-only

Every workflow has only `workflow_dispatch` (and `ci.yml` additionally has `workflow_call`). There is no `pull_request:`, no `push:` to `main`, no `paths:` filter, anywhere.

This is by design. `.github/scripts/docs_drift_check.sh` actively forbids legacy narrative tokens: a "merge-to-main" trigger phrase, the "PR plan" phrase against `infra/**`, and any docs reference to the legacy public-endpoint port. The script also requires `workflow_dispatch:` to be present in `ci.yml`, `infra-plan.yml`, `infra-apply.yml`, and `app-deploy.yml` (lines 30-34 of the script), confirming manual-dispatch is canonical.

Documentation drift inside `CLAUDE.md` (sections 4 and 8) still describes the obsolete trigger model: "PR + workflow_call quality gate", "PR plan for infra/**", "Apply on main / dispatch". These are flagged "unverified - check repo rules" in the file itself but should be updated to the manual-only canon. (Out of scope for this pass; flagged here so a follow-up edit can land.)

`act` impact: none. Local invocation already targets `workflow_dispatch` events (or named jobs) explicitly:

```bash
act -W .github/workflows/ci.yml workflow_dispatch
act -W .github/workflows/infra-plan.yml workflow_dispatch
```

### Finding 6 (informational): post-deploy smoke URL is on the listener default port, not the legacy 8443

`app-deploy.yml:150` curls `https://java.talorlik.com/actuator/health` (port 443 default). The drift check forbids the legacy `:8443` literal in docs, so the workflow value is canonical. `CLAUDE.md` section 6 still cites the legacy port; same drift class as Finding 5. Out of scope here, flagged for follow-up.

### Finding 7 (informational): `compose-smoke` job under `act`

`ci.yml:100-158` runs `docker compose` and Playwright. Under `act`:

- The `--container-options=--group-add=0` line in `.actrc:39` adds the host's root group to the runner container so the bind-mounted `/var/run/docker.sock` is reachable. Required.
- The runner image pin `catthehacker/ubuntu:full-24.04` (`.actrc:19`) ships a docker CLI new enough to negotiate API >= 1.40 against OrbStack / Docker Engine 24+. Required.
- Playwright's `npx playwright install --with-deps chromium` calls `apt-get` via sudo. The full-24.04 image has both. Works.
- Both `actions/upload-artifact` invocations (surefire + Playwright) are gated `!env.ACT && always()`. Correct.

No change needed. Document the dependency chain (image, group-add, ryuk-disabled) in any onboarding readme that gets added later.

### Finding 8 (informational): `secrets: inherit` in `app-deploy.yml`

`app-deploy.yml:22` calls `ci.yml` with `secrets: inherit`. `ci.yml` does not reference any `${{ secrets.* }}` value, so the inherit is a no-op today, but it's the correct default and keeps future-proofing free.

`act` correctly forwards the loaded `--secret-file` contents through `workflow_call`, so this works locally too.

### Finding 10 (high, RESOLVED 2026-05-09): `app-deploy.yml` ECR docker login fails under `act`

Status: applied. `app-deploy.yml:68-92` now uses a dual-path login.

Symptom: `act -W .github/workflows/app-deploy.yml workflow_dispatch -j deploy`
reached `Build + push backend` and exited with `no basic auth credentials`
on `docker push`. The `aws-actions/amazon-ecr-login@v2.1.4` step's Main and
Post steps both ran in the act log (visible as
`Run aws-actions/amazon-ecr-login@...` and
`Run Post aws-actions/amazon-ecr-login@...`), but the credentials never
made it into `$HOME/.docker/config.json` in a way the subsequent
`docker push` could consume.

Diagnostic ruled out (catthehacker/ubuntu:full-24.04 inspected directly):

- No `credsStore` or `credHelpers` in the baked
  `/home/runner/.docker/config.json`. Login writes plain base64 `auths`
  entries, push reads them, no helper involved.
- No conflicting credential-helper binary on PATH that would silently swallow
  the login token. `docker-credential-ecr-login` and
  `docker-credential-gcloud` exist but are unreferenced.
- Docker CLI 28.0.4, runner uid `runner` (1001), `HOME=/home/runner`. No
  HOME mismatch between the action's exec context and subsequent run
  steps in the same job container.

Most likely residual cause (not deeply investigated, the fix bypasses it):
the action's JS path resolves AWS creds through the SDK and writes to the
docker config under whatever `HOME` the spawned `docker login` child
process inherits. Under `act`'s exec model, that has historically not
matched the run-step `HOME` in every release.

Fix: keep the action on real GitHub runners (Post-step logout, masked
password output, no behavior change), and replace it under `act` with a
direct shell login that uses the AWS CLI already installed by the
`Ensure AWS CLI present` step earlier in the job.

```yaml
- uses: aws-actions/amazon-ecr-login@19d944daaa35f0fa1d3f7f8af1d3f2e5de25c5b7 # v2.1.4
  if: ${{ env.ACT != 'true' }}
  id: ecr
  with:
    registries: ${{ vars.DEPLOYMENT_ACCOUNT_ID }}

- name: ECR docker login (act fallback)
  if: ${{ env.ACT == 'true' }}
  shell: bash
  run: |
    set -euo pipefail
    aws ecr get-login-password --region "${{ vars.AWS_REGION }}" \
      | docker login \
          --username AWS \
          --password-stdin \
          "${{ vars.DEPLOYMENT_ACCOUNT_ID }}.dkr.ecr.${{ vars.AWS_REGION }}.amazonaws.com"
```

Severity: high. Without the fallback, the build/push/refresh job is
unrunnable under `act`. No equivalent gap in any other workflow:
`app-destroy.yml` uses ECR API only (`aws ecr list-images`,
`aws ecr batch-delete-image`), no docker push; `infra-*` and `ci.yml`
do not push to ECR.

### Finding 11 (low, RESOLVED 2026-05-09): `AWS_PAGER` scope drift in `infra-apply.yml`

Status: applied. `infra-apply.yml:27-31` now sets `AWS_PAGER: ""` at job
level; the previous step-local override on `Upload compose file to S3
(compose-object pointer)` was removed as redundant.

Original analysis: the other three AWS-shelling workflows (`app-deploy.yml`,
`app-destroy.yml`, `infra-destroy.yml`) all set `env.AWS_PAGER: ""` at job
level, ensuring every `aws` shell-out under act's medium image (which has
no `less`) skips the default pager and avoids exit 253. `infra-apply.yml`
set it only on the S3-upload step, leaving the SLR creation, SSM
put-parameter, and terraform-output steps technically vulnerable to the
same failure mode whenever their JSON output exceeds a screenful. Today
their output is short, so the issue was latent rather than active.

No behavior change on hosted GitHub runners, which have `less` installed
and ignore the variable when output fits.

### Finding 9 (informational): vars vs secrets split

The split is consistent across all five infra/app workflows:

- `secrets`: anything that looks like an ARN with an account ID embedded (`DEPLOYMENT_ROLE_ARN`, `DOMAIN_ROUTE53_ROLE_ARN`, `ACM_CERTIFICATE_ARN`).
- `vars`: numeric account IDs, region, hosted zone ID.

`CLAUDE.md` section 7 lists all of these together as "GitHub repository variables" without distinguishing the two surfaces. Minor doc drift; functionally aligned. Flag for the same CLAUDE.md cleanup pass that handles Findings 5 and 6.

---

## 3. Reference invocations under `act`

All commands assume the working directory is the repo root and that
`.github/{env,secrets,vars}.local` have been populated from the `.example`
companions. `.actrc` flags load automatically.

```bash
# CI gate (mirrors what app-deploy reuses).
act -W .github/workflows/ci.yml workflow_dispatch

# CI, single job (avoids the heavy compose-smoke).
act -W .github/workflows/ci.yml workflow_dispatch -j backend
act -W .github/workflows/ci.yml workflow_dispatch -j iac-checks

# Infra plan (after Finding 1 is applied; today the OIDC step blocks act).
act -W .github/workflows/infra-plan.yml workflow_dispatch

# Infra apply / destroy: do NOT run via act. Hard rule from CLAUDE.md
# section 10; the workflows themselves still call `terraform apply` /
# `terraform destroy`. Local validation should stop at `terraform plan`.

# App-deploy build-only loop. The deploy job pushes to ECR and refreshes
# the live ASG; restrict act to the build-test gate via -j.
act -W .github/workflows/app-deploy.yml workflow_dispatch -j build-test

# App-destroy: same caution. Today blocked under act by Finding 2.
```

Useful flags for ad-hoc runs (override `.actrc` per-invocation):

```bash
# Dry-run plan only (list jobs and steps without executing).
act -W .github/workflows/ci.yml workflow_dispatch -n

# Verbose with per-step timing.
act -W .github/workflows/ci.yml workflow_dispatch --verbose

# Override the runner image temporarily (e.g., to test on the slim image).
act -P ubuntu-latest=catthehacker/ubuntu:act-latest -W .github/workflows/ci.yml workflow_dispatch
```

---

## 4. Summary of required changes

| # | File | Lines | Change | Severity | Status |
|---|---|---|---|---|---|
| 1 | `.github/workflows/infra-plan.yml` | 26 | add `if: ${{ env.ACT != 'true' }}` to `aws-actions/configure-aws-credentials` step | high | RESOLVED 2026-05-09 |
| 2 | `.github/workflows/app-destroy.yml` | 79 | add `if: ${{ env.ACT != 'true' }}` to `aws-actions/configure-aws-credentials` step | high | RESOLVED 2026-05-09 |
| 3 | `.github/{env,secrets,vars}.local.example` | new | publish templates referenced by `.actrc` | done | done in original pass |
| 4 | `CLAUDE.md` (sections 4, 6, 7, 8) | n/a | reconcile narrative with manual-dispatch trigger model and listener-default smoke URL | low | open follow-up |
| 5 | `.github/workflows/app-deploy.yml` | 68-92 | dual-path ECR docker login: real GitHub runners keep `aws-actions/amazon-ecr-login@v2.1.4` (gated `if: env.ACT != 'true'`), `act` runs `aws ecr get-login-password \| docker login --password-stdin` (gated `if: env.ACT == 'true'`) | high | RESOLVED 2026-05-09 |
| 6 | `.github/workflows/infra-apply.yml` | 27-31, 121-126 | promote `AWS_PAGER: ""` from step-local to job-level for parity with the other AWS-shelling workflows | low | RESOLVED 2026-05-09 |

Items 1, 2, 5, 6 are the workflow edits required to bring local `act` and
remote GitHub into full alignment; all four landed on 2026-05-09. Item 3
was a missing onboarding artifact, resolved in the original pass. Item 4
is documentation drift outside the workflow surface itself; flag and defer.

The original pass produced no workflow edits and recommended applying
items 1 and 2 after explicit confirmation. Both were applied later the
same day, along with items 5 and 6 discovered during a re-run.

# 06 - Local execution with act

Run the GitHub Actions workflows locally against real AWS using
`nektos/act`. The workflow YAML is written so the same job graph executes
on GitHub-hosted runners in production and on a developer Mac under act,
guarded by `if: env.ACT != 'true'` for OIDC-only steps.

This file is the operator handoff for the local path. The deploy/destroy
sequence on real CI is `03-deployment.md`. Hard rules in `CLAUDE.md`
section 10 (no `terraform apply` from agent context, no SSH ingress, no
`latest` tags, etc.) apply unchanged.

## 1. Prerequisites

- macOS host with one of: Docker Desktop, OrbStack, or Colima running.
  The pinned runner image (`catthehacker/ubuntu:full-24.04`, set in
  `.actrc`) is approximately 18 GB on first pull.
- `act` installed: `brew install act`. Tested with `act >= 0.2.66`
  (unverified - run `act --version`).
- AWS credentials with the same surface area as the DEPLOYMENT account's
  `github-role`. Short-lived STS sessions are preferred; obtain via
  `aws sts get-session-token` or AWS IAM Identity Center.
- Bootstrap state stack already applied for the target account
  (`infra/bootstrap`, run once - see `01-bootstrap-state.md`).
- All standard CLI/runtime tools listed in `00-prerequisites.md`.

## 2. File layout

| Path                              | Source-controlled? | Purpose                                                                   |
| --------------------------------- | ------------------ | ------------------------------------------------------------------------- |
| `.actrc`                          | yes                | Default flags: runner image, arch, env/secret/var file paths              |
| `.github/env.local.example`       | yes                | Template for AWS creds and ACT-specific env                               |
| `.github/secrets.local.example`   | yes                | Template for repo-scoped GitHub `secrets.*`                               |
| `.github/vars.local.example`      | yes                | Template for repo-scoped GitHub `vars.*`                                  |
| `.github/env.local`               | no (gitignored)    | Real env-file values (AWS keys, `AWS_REGION`, `ACT=true`, etc.)           |
| `.github/secrets.local`           | no (gitignored)    | Real per-repo secrets only (ARNs, optional `GH_TOKEN`)                    |
| `.github/vars.local`              | no (gitignored)    | Real per-repo vars (account IDs, hosted zone)                             |
| `~/.act/.secrets`                 | no (host-level)    | Cross-project shared secrets, primarily Docker registry auth              |

## 3. Why a host-level `~/.act/.secrets`

Docker registry credentials are not repo-scoped. The same
`DOCKER_USERNAME` / `DOCKER_PASSWORD` (or PAT) are reused across every
project that pulls or pushes container images. Copying them into each
repo's `secrets.local` duplicates the secret and widens the blast
radius on a single leak.

Keeping them in `~/.act/.secrets`:

- One file, one rotation point. Rotating the Docker PAT updates every
  consumer at once.
- The repo's `.github/secrets.local` stays minimal, holding only
  genuinely repo-scoped values (the three IAM/ACM ARNs and a
  `GH_TOKEN` if a workflow needs the GitHub API).
- The host file lives outside any git workspace, so an accidental
  `git add -A` cannot stage it.

`act` accepts `--secret-file` exactly once. The two files are merged at
invocation time using shell process substitution:

```bash
--secret-file <(cat ~/.act/.secrets ./.github/secrets.local)
```

`<(...)` exposes the concatenated stream as a file descriptor `act`
reads from. When the same key is defined in both, the later definition
wins, so ordering is `~/.act/.secrets` first and the repo file second
- per-repo overrides take precedence.

## 4. One-time host setup

```bash
mkdir -p ~/.act
touch ~/.act/.secrets
chmod 700 ~/.act
chmod 600 ~/.act/.secrets
```

Populate `~/.act/.secrets` with cross-project shared values. Only list
keys actually consumed by the workflows you run:

```ini
# ~/.act/.secrets - shared across every repo's act runs.
# 0600, owned by you. Never commit, never sync to cloud storage.

# Docker Hub or other registry. Use a token, not an account password.
DOCKER_USERNAME=your_dockerhub_username
DOCKER_PASSWORD=dckr_pat_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Optional shared GitHub PAT. Repo-specific GH_TOKEN values still
# belong in .github/secrets.local and will override this one because
# the cat order puts the repo file last.
# GH_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Verify mode and ownership:

```bash
stat -f '%Sp %Su %N' ~/.act/.secrets
# expect: -rw-------  <your-user>  /Users/<you>/.act/.secrets
```

Optional hardening: add `~/.act/` to your shell's umask-protected paths,
exclude it from any cloud-sync tools (iCloud Drive, Dropbox, Backblaze
selective backup), and consider routing rotation through a password
manager that exports a flat `KEY=VALUE` file.

## 5. Per-repo setup

From the repo root, copy each `.example` file to its real sibling and
fill in values:

```bash
cp .github/env.local.example     .github/env.local
cp .github/secrets.local.example .github/secrets.local
cp .github/vars.local.example    .github/vars.local
chmod 600 .github/env.local .github/secrets.local .github/vars.local
```

`.github/env.local` - AWS credentials for the runner container (act
bypasses OIDC; the `aws-actions/configure-aws-credentials` step is
guarded by `if: env.ACT != 'true'` in `infra-apply.yml`,
`infra-destroy.yml`, `app-deploy.yml`):

```ini
ACT=true

AWS_ACCESS_KEY_ID=ASIA...
AWS_SECRET_ACCESS_KEY=...
AWS_SESSION_TOKEN=...
AWS_REGION=us-east-1
AWS_DEFAULT_REGION=us-east-1

AWS_PAGER=
TESTCONTAINERS_RYUK_DISABLED=true
DOCKER_HOST=unix:///var/run/docker.sock
```

`.github/secrets.local` - only repo-scoped secrets:

```ini
DEPLOYMENT_ROLE_ARN=arn:aws:iam::<DEPLOYMENT_ACCOUNT_ID>:role/github-role
DOMAIN_ROUTE53_ROLE_ARN=arn:aws:iam::<DOMAIN_ACCOUNT_ID>:role/route53-dns-manager-role
ACM_CERTIFICATE_ARN=arn:aws:acm:us-east-1:<DEPLOYMENT_ACCOUNT_ID>:certificate/<uuid>
GH_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

`.github/vars.local` - non-secret repo config:

```ini
LOCAL_AWS_PROFILE=<your-aws-profile-or-blank>
AWS_REGION=us-east-1
DEPLOYMENT_ACCOUNT_ID=<12-digit>
DOMAIN_ACCOUNT_ID=<12-digit>
HOSTED_ZONE_ID=Z...
```

All three per-repo files are listed in `.gitignore`. Verify:

```bash
git check-ignore -v .github/env.local \
                    .github/secrets.local \
                    .github/vars.local
```

## 6. Sanity checks before first run

```bash
docker info >/dev/null && echo "docker ok"
act --version
act -l                            # list workflows act can see
aws sts get-caller-identity       # creds match DEPLOYMENT account
test -f ~/.act/.secrets && echo "host-level secrets present"
```

First-ever run on a clean host: drop `--pull=false` once so act pulls
`catthehacker/ubuntu:full-24.04`. All subsequent runs keep the flag for
speed.

## 7. INFRA APPLY

Run in this order. Each `\` is a shell line continuation; the command
is a single logical invocation.

### 7.1. Apply infrastructure (VPC, ALB, RDS, ECR, IAM, ACM wiring)

```bash
act workflow_dispatch \
    -W .github/workflows/infra-apply.yml \
    --input purge_pending_secrets=true \
    --secret-file <(cat ~/.act/.secrets ./.github/secrets.local) \
    --pull=false
```

Flags:

- `workflow_dispatch` - matches the workflow's only declared trigger.
- `-W <path>` - explicit workflow path; prevents act from running every
  workflow it discovers under `.github/workflows/`.
- `--input purge_pending_secrets=true` - if a previous destroy left
  the four `/java-app/prod/*` secrets in `PendingDeletion`, this
  forces deletion of those pending entries before terraform apply
  recreates them. Safe on a first apply (no-op when nothing is
  pending). Reference: `04-operations.md` ->
  "Re-apply after a destroy (pending-deletion secrets)".
- `--secret-file <(cat ...)` - merges host-level Docker creds with the
  repo's secrets in one stream.
- `--pull=false` - skip pulling the runner image on every run.

### 7.2. Build/push images and roll the ASG

```bash
act workflow_dispatch \
    -W .github/workflows/app-deploy.yml \
    --secret-file <(cat ~/.act/.secrets ./.github/secrets.local) \
    --pull=false
```

What it does (mirrors `03-deployment.md` step 4):

1. Calls `ci.yml` as a quality gate (unit, integration, smoke, IaC).
2. Builds `app/backend` and `app/frontend` images, tagged
   `sha-<short>` (12-char SHA).
3. Pushes to ECR. ECR auth uses `aws ecr get-login-password`; Docker
   Hub auth (if any base image is private-mirrored) uses the
   `DOCKER_USERNAME`/`DOCKER_PASSWORD` from `~/.act/.secrets`.
4. Updates SSM release params:
   `/java-app/prod/backend-image-tag`,
   `/java-app/prod/frontend-image-tag`,
   `/java-app/prod/release-id`.
5. Triggers ASG instance refresh, polls until `Successful`
   (`min_healthy_percentage = 100`,
   `max_healthy_percentage = 200`).
6. Smoke-checks `https://java.talorlik.com/actuator/health`.

To pin a specific tag (rollback or re-deploy a known-good build):

```bash
act workflow_dispatch \
    -W .github/workflows/app-deploy.yml \
    --input image_tag=sha-1234567890ab \
    --secret-file <(cat ~/.act/.secrets ./.github/secrets.local) \
    --pull=false
```

## 8. INFRA DESTROY

Run in this order. App layer first (drains traffic, empties ECR,
resets release pointers), then infra (terraform destroy of the env
stack). The bootstrap state stack stays intact by design.

### 8.1. Tear down the application layer

```bash
act workflow_dispatch \
    -W .github/workflows/app-destroy.yml \
    --input 'confirm=DESTROY' \
    --secret-file <(cat ~/.act/.secrets ./.github/secrets.local) \
    --pull=false
```

`--input 'confirm=DESTROY'` - typed-confirmation guard required by
`app-destroy.yml`. Single-quoted to prevent shell re-evaluation.

### 8.2. Tear down the infrastructure layer

```bash
act workflow_dispatch \
    -W .github/workflows/infra-destroy.yml \
    --input 'confirm=DESTROY' \
    --secret-file <(cat ~/.act/.secrets ./.github/secrets.local) \
    --pull=false
```

After this completes:

- The four app secrets (`/java-app/prod/db/app-user`,
  `/java-app/prod/admin`, `/java-app/prod/jwt`, `/java-app/prod/ses`)
  remain in `PendingDeletion` for 7 days.
- Re-applying within that window must include
  `--input purge_pending_secrets=true` (already in section 7.1).
- The bootstrap S3 state bucket and its KMS CMK are intentionally
  preserved so the next apply rehydrates the env without
  re-bootstrapping. To remove the bootstrap stack as well, follow the
  manual procedure in the root `README.md`.

## 9. Troubleshooting

- `Unable to get the ACTIONS_RUNTIME_TOKEN env variable` - artifact
  server missing. `.actrc` already sets
  `--artifact-server-path /tmp/act-artifacts`. If you override `.actrc`
  per-run, re-pass that flag.
- `client version 1.32 is too old` from Testcontainers - you are on
  the slim `act-latest` image. Stay on the pinned
  `catthehacker/ubuntu:full-24.04` (set in `.actrc`).
- `host.docker.internal` not resolving inside the runner - on plain
  Docker Engine on Linux, append
  `--container-options "--group-add=0 --add-host=host.docker.internal:host-gateway"`
  to the act invocation. macOS Desktop/OrbStack inject the alias
  natively, so `.actrc`'s default `--container-options=--group-add=0`
  is sufficient there.
- `credentials could not be found` inside `terraform plan` - check
  `.github/env.local`. STS session tokens expire; re-run
  `aws sts get-session-token` and overwrite the three `AWS_*` keys.
- Permissions warning on `~/.act/.secrets` - ensure mode `600`. act
  reads it regardless, but a world-readable secrets file is its own
  problem.
- Image pull saturating the link - run once with `--pull=true` to
  cache `catthehacker/ubuntu:full-24.04`, then keep `--pull=false`
  for subsequent runs.

## 10. Hard rules (mirrors `CLAUDE.md` section 10)

- Never paste live AWS access keys into `.github/secrets.local`. That
  file maps to `${{ secrets.* }}` references only. AWS credentials
  belong in `.github/env.local` and are picked up by the AWS SDK
  default credential chain inside the runner.
- Never commit `~/.act/.secrets`, `.github/env.local`,
  `.github/secrets.local`, or `.github/vars.local`. The three per-repo
  files are gitignored; the host-level file lives outside the repo by
  design.
- Never run `terraform apply` or `terraform destroy` from a shell
  during agent-driven runs. The act flow above goes through the
  workflows, which is the supported path.
- Never deploy or tag `latest`. Always `sha-<short>` or an explicit
  semver, matching section 10 of `CLAUDE.md`.

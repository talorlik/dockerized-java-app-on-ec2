# 03 - Deployment

## End-to-end sequence

All deploy and destroy workflows are `workflow_dispatch` only. They are
never triggered by `push` or PR events; you (or your CI orchestrator)
must invoke them explicitly.

1. Run `infra/bootstrap` once (see `01-bootstrap-state.md`).
2. Configure GitHub vars, secrets, and the `prod` Environment (see
   `00-prerequisites.md`).
3. Trigger `infra-apply.yml` manually (`gh workflow run infra-apply.yml`).
   The job:
   - `terraform init` against the bootstrap state bucket.
   - `plan` and `apply` with TF_VARs sourced from GitHub vars/secrets.
   - Uploads `app/docker/docker-compose.prod.yml` to a private S3 bucket
     (`java-app-prod-config-<account>`) and points the
     `/java-app/prod/compose-object` SSM parameter at it.
4. Trigger `app-deploy.yml` (`gh workflow run app-deploy.yml`). It:
   - Runs `ci.yml` as a gate (unit, integration, smoke, E2E, IaC).
   - Builds backend + frontend images tagged `sha-<short>` (12-char SHA).
   - Pushes to ECR.
   - Updates SSM release params (`backend-image-tag`,
     `frontend-image-tag`, `release-id`).
   - Starts an ASG instance refresh and polls until `Successful`.
   - Smoke checks `https://java.talorlik.com/actuator/health`.

## Manual override

```bash
gh workflow run app-deploy.yml -f image_tag=sha-1234567890ab
```

## Verifying success

```bash
# Public TLS handshake
curl -vI https://java.talorlik.com/actuator/health

# Healthy targets in the target group
TG_ARN=$(aws elbv2 describe-target-groups \
  --names java-app-prod-tg \
  --query 'TargetGroups[0].TargetGroupArn' --output text)
aws elbv2 describe-target-health --target-group-arn "$TG_ARN"

# Most recent instance refresh
aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name java-app-prod-asg \
  --max-records 1
```

## Admin login

```bash
aws secretsmanager get-secret-value \
  --secret-id /java-app/prod/admin \
  --query SecretString --output text | jq .
```

Use the `username`/`password` to log in at `https://java.talorlik.com/login`.

## Tear-down

Two workflows, in this order:

1. `gh workflow run app-destroy.yml -f confirm=DESTROY` -
   scales the ASG to 0, drains instances, resets the three SSM release
   pointers to `bootstrap`, deletes the published `docker-compose.prod.yml`
   from the config bucket, and empties both ECR repos.
2. `gh workflow run infra-destroy.yml -f confirm=DESTROY` -
   re-runs app cleanup if `run_app_cleanup=true` (default), disables ALB
   access logs and deletion protection, empties the ALB-logs and config
   buckets (versioned), removes the EC2 Auto Scaling and ELB
   service-linked roles from state, disables RDS deletion protection +
   purges retained automated backups, then runs `terraform destroy` with
   `TF_VAR_rds_skip_final_snapshot=true`,
   `TF_VAR_rds_delete_automated_backups=true`,
   `TF_VAR_alb_logs_force_destroy=true`,
   `TF_VAR_rds_deletion_protection=false`.

The bootstrap state stack (S3 state bucket + KMS CMK in
`infra/bootstrap`) is intentionally left intact so the next
`infra-apply.yml` can rehydrate the env without re-bootstrapping. To
remove it as well, see the manual procedure in the root `README.md`.

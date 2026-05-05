# 03 - Deployment

## End-to-end sequence

1. Run `infra/bootstrap` once (see `01-bootstrap-state.md`).
2. Configure GitHub vars + secrets (see `00-prerequisites.md`).
3. Push to `main`. `infra-apply.yml` runs:
   - `terraform init` against the bootstrap state bucket.
   - `plan` and `apply` with TF_VARs sourced from GitHub vars/secrets.
   - Uploads `app/docker/docker-compose.prod.yml` to a private S3 bucket
     (`java-app-prod-config-<account>`) and points the
     `/java-app/prod/compose-object` SSM parameter at it.
4. Push again (or wait for the `app-deploy.yml` workflow on the same merge):
   - Runs `ci.yml` as a gate (unit, integration, smoke, E2E, IaC).
   - Builds backend + frontend images tagged `sha-<short>`.
   - Pushes to ECR.
   - Updates SSM release params.
   - Starts ASG instance refresh and polls until `Successful`.
   - Smoke checks `https://java.talorlik.com:8443/actuator/health`.

## Manual override

```bash
gh workflow run app-deploy.yml -f image_tag=sha-1234567890ab
```

## Verifying success

```bash
# Public TLS handshake
curl -vI https://java.talorlik.com:8443/actuator/health

# Healthy targets in the target group
aws elbv2 describe-target-health \
  --target-group-arn $(terraform -chdir=infra/envs/prod output -raw alb_target_group_arn 2>/dev/null || echo "<lookup manually>")

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

Use the `username`/`password` to log in at `https://java.talorlik.com:8443/login`.

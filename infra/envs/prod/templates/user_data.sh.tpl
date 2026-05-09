#!/bin/bash
###############################################################################
# EC2 user-data: bootstrap a Docker Compose runtime for the Java app.
#
# Steps:
#   1. Install Docker Engine, Compose v2 plugin, AWS CLI v2, jq, CW Agent.
#   2. Pull image tags + DB endpoint from SSM and secrets from Secrets Manager.
#   3. Authenticate to ECR.
#   4. Render /opt/java-app/.env, fetch docker-compose.prod.yml from SSM-pointed
#      S3 URI, then `docker compose up -d`.
#   5. Configure CloudWatch Agent.
#   6. Poll the local actuator until it returns UP. If it never does, mark
#      this instance Unhealthy via the ASG API so it's replaced instead of
#      lingering as a black hole behind the ALB.
#
# Hardening notes:
#   - `set -x` echoes every command into the log to make boot regressions
#     diagnosable in CloudWatch.
#   - apt+curl operations retry; a transient apt mirror or download.docker.com
#     blip used to leave the box partially provisioned.
#   - Compose pull failure is no longer swallowed (was: `|| true`); a missing
#     image must fail the boot so the ASG replaces it.
###############################################################################
set -Eeuo pipefail
set -x

REGION="${aws_region}"
LOG_GROUP="${log_group_name}"

# ---- log everything to /var/log/user-data.log too ----
exec > >(tee -a /var/log/user-data.log /var/log/cloud-init-output.log) 2>&1

echo "[user-data] starting at $(date -Iseconds)"

# ---- generic retry helper: retry <attempts> <sleep_seconds> -- <cmd...> ----
retry() {
  local attempts="$1"; shift
  local delay="$1"; shift
  local i=0
  until "$@"; do
    i=$((i + 1))
    if (( i >= attempts )); then
      echo "[user-data] command failed after $i attempts: $*" >&2
      return 1
    fi
    echo "[user-data] attempt $i failed for: $*; sleeping $${delay}s"
    sleep "$delay"
  done
}

# ---- mark this instance Unhealthy in its ASG and exit non-zero ----
self_unhealthy() {
  local reason="$1"
  echo "[user-data] FATAL: $reason; marking instance Unhealthy" >&2
  local token
  token=$(curl -fsS --max-time 5 -X PUT "http://169.254.169.254/latest/api/token" \
            -H "X-aws-ec2-metadata-token-ttl-seconds: 300" || true)
  local iid
  iid=$(curl -fsS --max-time 5 -H "X-aws-ec2-metadata-token: $${token}" \
          "http://169.254.169.254/latest/meta-data/instance-id" || true)
  if [[ -n "$${iid}" ]]; then
    aws autoscaling set-instance-health \
      --region "$REGION" \
      --instance-id "$${iid}" \
      --health-status Unhealthy \
      --no-should-respect-grace-period || true
  fi
  exit 1
}
trap 'self_unhealthy "user-data trapped error on line $LINENO"' ERR

# ---- base packages ----
export DEBIAN_FRONTEND=noninteractive
retry 5 10 apt-get update -y
retry 5 10 apt-get install -y ca-certificates curl gnupg lsb-release jq unzip

# ---- Docker Engine + Compose plugin (official Docker apt repo) ----
install -m 0755 -d /etc/apt/keyrings
retry 5 5 bash -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg'
chmod a+r /etc/apt/keyrings/docker.gpg
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $${VERSION_CODENAME} stable" \
  | tee /etc/apt/sources.list.d/docker.list >/dev/null
retry 5 10 apt-get update -y
retry 5 10 apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker.service is enabled here so containers auto-start across instance
# stop/start cycles. Combined with `restart: unless-stopped` in compose,
# this is what makes the "containers must come back on machine reboot"
# requirement hold.
systemctl enable --now docker

# ---- AWS CLI v2 (apt awscli is v1; replace with v2) ----
retry 5 5 curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update
rm -rf /tmp/aws /tmp/awscliv2.zip

# ---- CloudWatch Agent ----
retry 5 5 curl -fsSL \
  "https://s3.${aws_region}.amazonaws.com/amazoncloudwatch-agent-${aws_region}/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb" \
  -o /tmp/cwa.deb
dpkg -i -E /tmp/cwa.deb || apt-get install -fy
rm -f /tmp/cwa.deb

# ---- App directory ----
mkdir -p /opt/java-app
cd /opt/java-app

# ---- Pull release metadata + DB endpoint from SSM ----
# All these parameters are SecureString under the app-secrets CMK (see
# infra/envs/prod/secrets.tf). --with-decryption is required; the EC2 instance
# role grants kms:Decrypt on aws_kms_key.app_secrets via the app_inline policy.
BACKEND_TAG=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_backend_tag}"  --query 'Parameter.Value' --output text)
FRONTEND_TAG=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_frontend_tag}" --query 'Parameter.Value' --output text)
RELEASE_ID=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_release_id}"   --query 'Parameter.Value' --output text)
DB_HOST=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_db_endpoint}"     --query 'Parameter.Value' --output text)
DB_NAME=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_db_name}"         --query 'Parameter.Value' --output text)
COMPOSE_OBJ=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_compose_object}" --query 'Parameter.Value' --output text)

# ---- Pull DB app-user creds from Secrets Manager ----
DB_USER_JSON=$(aws secretsmanager get-secret-value --region "$REGION" --secret-id "${secret_db_app_user}" --query 'SecretString' --output text)
DB_USER=$(echo "$DB_USER_JSON" | jq -r .username)
DB_PASS=$(echo "$DB_USER_JSON" | jq -r .password)

# JWT (only used by backend at runtime - pulled by the backend itself via
# Secrets Manager too; here we only export the secret name as an env var).
JWT_SECRET_NAME="${secret_jwt}"
SES_SECRET_NAME="${secret_ses}"
ADMIN_SECRET_NAME="${secret_admin}"

# ---- Render .env file (mode 0600, root-owned) ----
umask 077
cat >/opt/java-app/.env <<EOF
# Generated by user-data on $(date -Iseconds)
RELEASE_ID=$${RELEASE_ID}
BACKEND_IMAGE=${backend_repo_url}:$${BACKEND_TAG}
FRONTEND_IMAGE=${frontend_repo_url}:$${FRONTEND_TAG}

AWS_REGION=$${REGION}

DB_HOST=$${DB_HOST}
DB_PORT=3306
DB_NAME=$${DB_NAME}
DB_USERNAME=$${DB_USER}
DB_PASSWORD=$${DB_PASS}

JWT_SECRET_NAME=$${JWT_SECRET_NAME}
SES_SECRET_NAME=$${SES_SECRET_NAME}
ADMIN_SECRET_NAME=$${ADMIN_SECRET_NAME}

APP_PUBLIC_URL=https://${app_subdomain}
EOF
chmod 0600 /opt/java-app/.env

# ---- Fetch docker-compose.prod.yml from S3 (pointer in SSM) ----
if [[ "$${COMPOSE_OBJ}" == s3://* ]]; then
  retry 5 5 aws s3 cp "$${COMPOSE_OBJ}" /opt/java-app/docker-compose.yml
else
  echo "[user-data] WARNING: compose-object SSM value is '$${COMPOSE_OBJ}' (not s3:// URI)."
  # Sane default to keep the box up if compose isn't published yet.
  cat >/opt/java-app/docker-compose.yml <<'YAML'
services:
  placeholder:
    image: nginx:1.27-alpine
    ports: ["8080:80"]
    restart: unless-stopped
YAML
fi

# ---- ECR auth (with retry; ECR rate-limits cold logins occasionally) ----
retry 5 5 bash -c "aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${deployment_account}.dkr.ecr.$REGION.amazonaws.com"

# ---- Compose up ----
cd /opt/java-app
# `pull` failure must NOT be ignored: if a tag is missing, the box should
# fail provisioning and be replaced rather than start a stale image.
retry 3 10 docker compose --env-file /opt/java-app/.env pull
docker compose --env-file /opt/java-app/.env up -d --remove-orphans

# ---- CloudWatch Agent config ----
cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<JSON
{
  "agent": { "metrics_collection_interval": 60, "run_as_user": "root" },
  "metrics": {
    "namespace": "JavaApp/EC2",
    "append_dimensions": {
      "InstanceId": "\$${aws:InstanceId}",
      "AutoScalingGroupName": "\$${aws:AutoScalingGroupName}"
    },
    "metrics_collected": {
      "cpu":  { "measurement": ["cpu_usage_idle","cpu_usage_iowait","cpu_usage_user","cpu_usage_system"], "totalcpu": true },
      "mem":  { "measurement": ["mem_used_percent"] },
      "disk": { "measurement": ["used_percent"], "resources": ["/"] },
      "diskio": { "measurement": ["io_time"] }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          { "file_path": "/var/log/user-data.log",       "log_group_name": "$${LOG_GROUP}", "log_stream_name": "{instance_id}/user-data" },
          { "file_path": "/var/log/cloud-init-output.log","log_group_name": "$${LOG_GROUP}", "log_stream_name": "{instance_id}/cloud-init" },
          { "file_path": "/var/lib/docker/containers/*/*-json.log", "log_group_name": "$${LOG_GROUP}", "log_stream_name": "{instance_id}/docker" }
        ]
      }
    }
  }
}
JSON

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# ---- Wait for actuator/health BEFORE we hand off to the ASG. ----
# The ALB target group also probes /actuator/health, but it does so via the
# ALB SG path, which adds a DNS hop. Probing locally first lets us fail
# fast and self-mark Unhealthy if the app never comes up, instead of
# letting the ASG eventually time out the grace period.
echo "[user-data] waiting for /actuator/health on localhost:8080"
deadline=$(( $(date +%s) + 240 ))
ok=0
while (( $(date +%s) < deadline )); do
  if curl -fsS --max-time 5 "http://127.0.0.1:8080/actuator/health" | grep -q '"status":"UP"'; then
    ok=1
    break
  fi
  sleep 5
done

if (( ok != 1 )); then
  # Disable the trap so self_unhealthy runs cleanly.
  trap - ERR
  self_unhealthy "actuator never reported UP within 240s"
fi

# Disable the trap before exit so a benign cleanup doesn't trigger it.
trap - ERR
echo "[user-data] done at $(date -Iseconds)"

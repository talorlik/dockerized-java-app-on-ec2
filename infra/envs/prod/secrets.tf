###############################################################################
# Secrets Manager + KMS for application runtime secrets.
#
# - Master DB password is created by RDS-managed master credentials in rds.tf.
# - App-user DB password is created here (Terraform random_password) and must
#   be created inside MySQL via Flyway migration after RDS is up.
# - Admin bootstrap secret is generated and seeded by the backend's startup
#   routine if not already present.
# - JWT signing key is generated here.
# - SES sender config is a plain JSON struct of identity + region.
###############################################################################

# CMK for application secrets, SSM parameters, and CloudWatch log groups.
# Policy must allow CloudWatch Logs service to use the key for the specific
# log groups, otherwise CreateLogGroup fails with AccessDeniedException.
resource "aws_kms_key" "app_secrets" {
  description = "App secrets, SSM parameters, and log group encryption"
  # Dev default: KMS minimum (7). Re-apply creates a new key anyway; this
  # just minimizes how long the old pending-deletion key sits in the account.
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:${data.aws_partition.current.partition}:iam::${var.deployment_account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudWatchLogsUseOfKey"
        Effect    = "Allow"
        Principal = { Service = "logs.${var.aws_region}.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "*"
        Condition = {
          # ArnLike supports a list of patterns (any-match). The first covers
          # the application/VPC-flow log groups under /<project>/<env>/...;
          # the second covers AWS WAF logging targets, which must start with
          # "aws-waf-logs-" per the WAF logging-destination naming rule.
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = [
              "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${var.deployment_account_id}:log-group:/${var.project}/${var.environment}/*",
              "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${var.deployment_account_id}:log-group:aws-waf-logs-${var.project}-${var.environment}*",
            ]
          }
        }
      },
      {
        Sid       = "AllowSnsUseOfKey"
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = ["kms:Decrypt", "kms:GenerateDataKey*"]
        Resource  = "*"
      },
      {
        Sid       = "AllowEventsToPublishToSnsViaKey"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = ["kms:Decrypt", "kms:GenerateDataKey*"]
        Resource  = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "app_secrets" {
  name          = "alias/${local.name_prefix}-secrets"
  target_key_id = aws_kms_key.app_secrets.key_id
}

# ----------------------------------------------------------------------------
# Application DB user
# ----------------------------------------------------------------------------
resource "random_password" "db_app_user" {
  length           = 32
  special          = true
  override_special = "!#%&*+-=?_"
}

resource "random_password" "admin_bootstrap" {
  length  = 24
  special = false
}

resource "random_password" "jwt_signing" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "db_app_user" {
  # checkov:skip=CKV2_AWS_57:rotation Lambda is intentionally out of scope for this reference impl; rotation handled manually for dev-only env. Wire aws_secretsmanager_secret_rotation + a rotation Lambda for live use.
  name        = "${local.secret_prefix}/db/app-user"
  description = "App user credentials (least-privileged DB role)"
  kms_key_id  = aws_kms_key.app_secrets.arn
  # Dev default: 0 = delete immediately on `terraform destroy`. This avoids
  # the 7-day PendingDeletion window that otherwise blocks a re-apply with
  # the same secret name. Bump to 7-30 before going live.
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_app_user" {
  secret_id = aws_secretsmanager_secret.db_app_user.id
  secret_string = jsonencode({
    username = var.db_app_username
    password = random_password.db_app_user.result
  })
}

# ----------------------------------------------------------------------------
# Admin bootstrap (idempotent seed at startup)
# ----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "admin" {
  # checkov:skip=CKV2_AWS_57:bootstrap admin secret read once at app startup; rotation Lambda intentionally out of scope.
  name        = "${local.secret_prefix}/admin"
  description = "Bootstrap admin user. Read once at app startup."
  kms_key_id  = aws_kms_key.app_secrets.arn
  # Dev default: 0 = delete immediately on `terraform destroy`. This avoids
  # the 7-day PendingDeletion window that otherwise blocks a re-apply with
  # the same secret name. Bump to 7-30 before going live.
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin" {
  secret_id = aws_secretsmanager_secret.admin.id
  secret_string = jsonencode({
    username = "admin@${var.root_domain}"
    password = random_password.admin_bootstrap.result
  })
}

# ----------------------------------------------------------------------------
# JWT signing secret
# ----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "jwt" {
  # checkov:skip=CKV2_AWS_57:JWT signing key rotation requires coordinated app-side key roll; rotation Lambda intentionally out of scope for this reference impl.
  name        = "${local.secret_prefix}/jwt"
  description = "HMAC signing key for backend JWT"
  kms_key_id  = aws_kms_key.app_secrets.arn
  # Dev default: 0 = delete immediately on `terraform destroy`. This avoids
  # the 7-day PendingDeletion window that otherwise blocks a re-apply with
  # the same secret name. Bump to 7-30 before going live.
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id = aws_secretsmanager_secret.jwt.id
  secret_string = jsonencode({
    signing_key = random_password.jwt_signing.result
    issuer      = "https://${var.app_subdomain}"
  })
}

# ----------------------------------------------------------------------------
# SES sender config
# ----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "ses" {
  # checkov:skip=CKV2_AWS_57:SES sender config is non-credential JSON (region+identity); rotation does not apply.
  name        = "${local.secret_prefix}/ses"
  description = "SES sender identity / region configuration"
  kms_key_id  = aws_kms_key.app_secrets.arn
  # Dev default: 0 = delete immediately on `terraform destroy`. This avoids
  # the 7-day PendingDeletion window that otherwise blocks a re-apply with
  # the same secret name. Bump to 7-30 before going live.
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ses" {
  secret_id = aws_secretsmanager_secret.ses.id
  secret_string = jsonencode({
    region        = var.aws_region
    sender_domain = var.ses_sender_subdomain
    from_address  = var.ses_from_address
  })
}

# ----------------------------------------------------------------------------
# Non-secret runtime config (kept as SSM Parameter Store, not Secrets Manager)
# ----------------------------------------------------------------------------
resource "aws_ssm_parameter" "compose_object" {
  # The instance user data downloads docker-compose.prod.yml from this
  # location. The value is set later via CI (or by an operator copying the
  # compose file to S3 and writing the s3:// URI here).
  # SecureString + CMK to satisfy CKV2_AWS_34 (operationally the value is
  # an s3:// URI, not a secret, but encryption is cheap and uniform).
  name        = local.ssm_keys.compose_object
  description = "S3 URI of docker-compose.prod.yml used by EC2 user data"
  type        = "SecureString"
  key_id      = aws_kms_key.app_secrets.key_id
  value       = "PENDING"

  lifecycle {
    # CI updates the value via `aws ssm put-parameter --overwrite`; ignore so
    # Terraform doesn't revert it on next apply. Same applies to the three
    # release-pointer params below.
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "backend_image_tag" {
  name        = local.ssm_keys.backend_image_tag
  description = "Backend image tag (commit SHA) consumed by user data"
  type        = "SecureString"
  key_id      = aws_kms_key.app_secrets.key_id
  value       = var.initial_backend_image_tag

  lifecycle {
    # CI/CD updates this on each release; we don't want Terraform to revert it.
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "frontend_image_tag" {
  name   = local.ssm_keys.frontend_image_tag
  type   = "SecureString"
  key_id = aws_kms_key.app_secrets.key_id
  value  = var.initial_frontend_image_tag
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "release_id" {
  name   = local.ssm_keys.release_id
  type   = "SecureString"
  key_id = aws_kms_key.app_secrets.key_id
  value  = "bootstrap"
  lifecycle {
    ignore_changes = [value]
  }
}

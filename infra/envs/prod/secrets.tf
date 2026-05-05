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

# CMK for application secrets
resource "aws_kms_key" "app_secrets" {
  description             = "App secrets and SSM parameters"
  deletion_window_in_days = 30
  enable_key_rotation     = true
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
  name                    = "${local.secret_prefix}/db/app-user"
  description             = "App user credentials (least-privileged DB role)"
  kms_key_id              = aws_kms_key.app_secrets.arn
  recovery_window_in_days = 7
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
  name                    = "${local.secret_prefix}/admin"
  description             = "Bootstrap admin user. Read once at app startup."
  kms_key_id              = aws_kms_key.app_secrets.arn
  recovery_window_in_days = 7
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
  name                    = "${local.secret_prefix}/jwt"
  description             = "HMAC signing key for backend JWT"
  kms_key_id              = aws_kms_key.app_secrets.arn
  recovery_window_in_days = 7
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
  name                    = "${local.secret_prefix}/ses"
  description             = "SES sender identity / region configuration"
  kms_key_id              = aws_kms_key.app_secrets.arn
  recovery_window_in_days = 7
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
  name        = local.ssm_keys.compose_object
  description = "S3 URI of docker-compose.prod.yml used by EC2 user data"
  type        = "String"
  value       = "PENDING"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "backend_image_tag" {
  name        = local.ssm_keys.backend_image_tag
  description = "Backend image tag (commit SHA) consumed by user data"
  type        = "String"
  value       = var.initial_backend_image_tag

  lifecycle {
    # CI/CD updates this on each release; we don't want Terraform to revert it.
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "frontend_image_tag" {
  name  = local.ssm_keys.frontend_image_tag
  type  = "String"
  value = var.initial_frontend_image_tag
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "release_id" {
  name  = local.ssm_keys.release_id
  type  = "String"
  value = "bootstrap"
  lifecycle {
    ignore_changes = [value]
  }
}

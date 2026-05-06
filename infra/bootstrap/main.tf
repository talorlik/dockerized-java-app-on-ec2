###############################################################################
# infra/bootstrap/main.tf
#
# Creates the prerequisites for remote Terraform state in the DEPLOYMENT
# account:
#   - KMS CMK with alias for state encryption (CMK is preferred over SSE-S3
#     to enable per-key access policies and rotation control)
#   - S3 bucket for state with versioning, public access block, TLS-only
#     bucket policy, and SSE-KMS default encryption
#   - Optional access-log bucket
#
# State backend uses S3 native locking via `use_lockfile = true` (no DynamoDB).
###############################################################################

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# ----------------------------------------------------------------------------
# KMS CMK for state-bucket encryption
# ----------------------------------------------------------------------------
resource "aws_kms_key" "tfstate" {
  description             = "KMS key for Terraform state bucket (${var.state_bucket_name})"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "tfstate" {
  name          = var.kms_alias
  target_key_id = aws_kms_key.tfstate.key_id
}

# ----------------------------------------------------------------------------
# Optional access-log bucket
# ----------------------------------------------------------------------------
resource "aws_s3_bucket" "access_logs" {
  count         = var.enable_access_logging ? 1 : 0
  bucket        = "${var.state_bucket_name}-access-logs"
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count                   = var.enable_access_logging ? 1 : 0
  bucket                  = aws_s3_bucket.access_logs[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "access_logs" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ----------------------------------------------------------------------------
# Terraform state bucket
# ----------------------------------------------------------------------------
# NOTE: force_destroy is intentionally false. State buckets must never be
# accidentally emptied.
resource "aws_s3_bucket" "tfstate" {
  bucket        = var.state_bucket_name
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tfstate.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_logging" "tfstate" {
  count         = var.enable_access_logging ? 1 : 0
  bucket        = aws_s3_bucket.tfstate.id
  target_bucket = aws_s3_bucket.access_logs[0].id
  target_prefix = "tfstate-access/"
}

# Enforce TLS for all requests against the state bucket
resource "aws_s3_bucket_policy" "tfstate_tls_only" {
  bucket = aws_s3_bucket.tfstate.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.tfstate.arn,
          "${aws_s3_bucket.tfstate.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Lifecycle: keep noncurrent versions for 90 days, abort incomplete uploads
resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "expire-noncurrent"
    status = "Enabled"

    # Empty filter applies the rule to every object in the bucket. Required by
    # AWS provider v5 SDKv2 schema (one of `filter` or `prefix` is mandatory).
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

###############################################################################
# ALB - public, HTTPS on 443 (with HTTP/80 -> HTTPS redirect), ACM cert from
# DEPLOYMENT account.
#
# Target group is on HTTP 8080 against EC2 instances. Access logs land in S3.
###############################################################################

# ----------------------------------------------------------------------------
# ALB access log bucket
# ----------------------------------------------------------------------------

# AWS-owned ELB account ID per region (us-east-1 specifically).
# Reference: AWS docs - ELB access logs require account-scoped delivery perms.
locals {
  elb_log_account_id_by_region = {
    "us-east-1"      = "127311923021"
    "us-east-2"      = "033677994240"
    "us-west-1"      = "027434742980"
    "us-west-2"      = "797873946194"
    "eu-west-1"      = "156460612806"
    "eu-central-1"   = "054676820928"
    "ap-southeast-1" = "114774131450"
    "ap-southeast-2" = "783225319266"
    "ap-northeast-1" = "582318560864"
  }
  elb_log_account_id = lookup(local.elb_log_account_id_by_region, var.aws_region, "127311923021")
}

resource "aws_s3_bucket" "alb_logs" {
  bucket        = "${local.name_prefix}-alb-logs-${var.deployment_account_id}"
  force_destroy = var.alb_logs_force_destroy
  tags          = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    # ALB log delivery requires SSE-S3 (AES256), not SSE-KMS, for older
    # account-id-based grant; keep AES256 for compatibility.
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    id     = "expire"
    status = "Enabled"

    # Empty filter = applies to all objects (required by aws provider 5.x).
    filter {}

    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

data "aws_iam_policy_document" "alb_logs" {
  # Legacy regions (incl. us-east-1): writes come from the per-region ELB
  # AWS-owned account. Source: AWS docs - "Enable access logs for your
  # Application Load Balancer".
  statement {
    sid       = "AllowELBAccountPutObject"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_logs.arn}/AWSLogs/${var.deployment_account_id}/*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${local.elb_log_account_id}:root"]
    }
  }

  # Newer regions / future-proofing: writes come from the ELB log-delivery
  # service principal. Harmless in legacy regions.
  statement {
    sid       = "AllowELBLogDeliveryServicePut"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_logs.arn}/AWSLogs/${var.deployment_account_id}/*"]
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowELBLogDeliveryServiceGetAcl"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.alb_logs.arn]
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }
  }

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.alb_logs.arn, "${aws_s3_bucket.alb_logs.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.alb_logs.json
}

# ----------------------------------------------------------------------------
# ALB
# ----------------------------------------------------------------------------
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.10"

  name               = "${local.name_prefix}-alb"
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.alb.id]

  enable_deletion_protection = true
  drop_invalid_header_fields = true
  idle_timeout               = 60

  access_logs = {
    bucket  = aws_s3_bucket.alb_logs.id
    enabled = true
    # No prefix - keeps bucket-policy resource path simple as
    # bucket-arn/AWSLogs/<account>/*. If you reintroduce a prefix here,
    # you must add the same prefix to the s3:PutObject Resource list in
    # data "aws_iam_policy_document" "alb_logs".
  }

  listeners = {
    # Public HTTPS - terminates TLS using the wildcard ACM cert and forwards
    # to the app target group on HTTP/8080.
    https = {
      port            = local.alb_https_port
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = var.acm_certificate_arn

      forward = {
        target_group_key = "app"
      }
    }

    # Public HTTP - 301 redirect to HTTPS so users typing
    # http://java.talorlik.com land on the secure URL automatically.
    http_redirect = {
      port     = local.alb_http_port
      protocol = "HTTP"

      redirect = {
        port        = tostring(local.alb_https_port)
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  # Ensure the ELB SLR is in place before creating the ALB.
  depends_on = [aws_iam_service_linked_role.elb]

  target_groups = {
    app = {
      name                 = "${local.name_prefix}-tg"
      backend_protocol     = "HTTP"
      backend_port         = local.app_port
      target_type          = "instance"
      deregistration_delay = 30
      protocol_version     = "HTTP1"

      # Don't auto-register - the ASG handles target registration.
      create_attachment = false

      health_check = {
        enabled             = true
        path                = "/actuator/health"
        protocol            = "HTTP"
        port                = "traffic-port"
        matcher             = "200"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 15
        timeout             = 5
      }

      stickiness = {
        enabled = false
        type    = "lb_cookie"
      }
    }
  }

  tags = local.common_tags
}

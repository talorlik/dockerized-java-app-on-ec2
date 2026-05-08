###############################################################################
# AWS WAFv2 Web ACL attached to the ALB.
###############################################################################

resource "aws_wafv2_web_acl" "alb" {
  count       = var.enable_waf ? 1 : 0
  name        = "${local.name_prefix}-waf"
  description = "Web ACL for app ALB"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  # AWS-managed: Common Rule Set
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  # AWS-managed: Known Bad Inputs
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "known-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  # AWS-managed: SQL injection
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "sqli"
      sampled_requests_enabled   = true
    }
  }

  # Rate limit per source IP
  rule {
    name     = "RateLimitPerIp"
    priority = 10

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-ip"
      sampled_requests_enabled   = true
    }
  }

  tags = local.common_tags
}

resource "aws_wafv2_web_acl_association" "alb" {
  count        = var.enable_waf ? 1 : 0
  resource_arn = module.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.alb[0].arn
}

# ----------------------------------------------------------------------------
# WAF logging configuration
#
# CKV2_AWS_31 requires every wafv2 ACL to have a logging configuration. We
# ship logs to a CloudWatch log group whose name MUST start with
# "aws-waf-logs-" (AWS WAF logging-destination naming requirement). The log
# group is encrypted with the same app CMK used for other log groups.
# ----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "waf" {
  count = var.enable_waf ? 1 : 0
  # checkov:skip=CKV_AWS_338:dev-only environment, intentional short retention. Bump var.log_retention_days for live use.
  name              = "aws-waf-logs-${local.name_prefix}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.app_secrets.arn
  tags              = local.common_tags
}

resource "aws_wafv2_web_acl_logging_configuration" "alb" {
  count                   = var.enable_waf ? 1 : 0
  resource_arn            = aws_wafv2_web_acl.alb[0].arn
  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]
}

###############################################################################
# main.tf
#
# Account-context guard. The actual resources are split across domain-scoped
# files (network.tf, security.tf, secrets.tf, rds.tf, ecr.tf, alb.tf, asg.tf,
# iam.tf, observability.tf, route53.tf).
###############################################################################

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

# DOMAIN-account caller identity, resolved via the aliased provider that
# assumes the Route53 DNS-write role. Used to assert the assumed role lands
# in the expected account.
data "aws_caller_identity" "domain" {
  provider = aws.domain
}

# Fail fast if the wrong DEPLOYMENT account is used or the provider region
# does not match var.aws_region. Catches a class of footgun where the
# operator has stale credentials or a misaligned region. terraform_data is
# built-in (no extra provider) and supports lifecycle.precondition.
resource "terraform_data" "account_guard" {
  input = data.aws_caller_identity.current.account_id

  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.current.account_id == var.deployment_account_id
      error_message = "Active credentials target account ${data.aws_caller_identity.current.account_id} but var.deployment_account_id is ${var.deployment_account_id}."
    }
    precondition {
      condition     = data.aws_region.current.name == var.aws_region
      error_message = "AWS provider region ${data.aws_region.current.name} does not match var.aws_region (${var.aws_region})."
    }
  }
}

# Fail fast if the DOMAIN-account assume_role lands in the wrong account.
# Same footgun class as account_guard but for the cross-account Route53
# provider alias.
resource "terraform_data" "domain_account_guard" {
  input = data.aws_caller_identity.domain.account_id

  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.domain.account_id == var.domain_account_id
      error_message = "DNS provider assumed into account ${data.aws_caller_identity.domain.account_id} but var.domain_account_id is ${var.domain_account_id}."
    }
  }
}

###############################################################################
# Providers
#
# Default `aws` provider:
#   Targets the DEPLOYMENT account. CI assumes the DEPLOYMENT_ROLE_ARN via
#   GitHub OIDC; the operator can also run locally with admin credentials.
#
# Aliased `aws.domain` provider:
#   Assumes a Route53-DNS-write role in the DOMAIN account so cross-account
#   alias records and SES DKIM CNAMEs can be managed from the same plan.
###############################################################################

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "domain"
  region = var.aws_region

  assume_role {
    role_arn     = var.domain_account_route53_role_arn
    session_name = "tf-${var.project}-${var.environment}"
  }

  default_tags {
    tags = local.common_tags
  }
}

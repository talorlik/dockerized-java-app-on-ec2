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

# Fail fast if the wrong account is used. Catches a class of footgun where the
# operator has stale credentials. terraform_data is built-in (no extra
# provider) and supports lifecycle.precondition.
resource "terraform_data" "account_guard" {
  input = data.aws_caller_identity.current.account_id

  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.current.account_id == var.deployment_account_id
      error_message = "Active credentials target account ${data.aws_caller_identity.current.account_id} but var.deployment_account_id is ${var.deployment_account_id}."
    }
  }
}

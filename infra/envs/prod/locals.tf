locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
  }

  # Secrets Manager namespace as defined in TR-SEC-001.
  secret_prefix = "/${var.project}/${var.environment}"

  # SSM Parameter Store keys (TR-REL-005).
  ssm_keys = {
    backend_image_tag  = "${local.secret_prefix}/backend-image-tag"
    frontend_image_tag = "${local.secret_prefix}/frontend-image-tag"
    release_id         = "${local.secret_prefix}/release-id"
    compose_object     = "${local.secret_prefix}/compose-object"
    db_endpoint        = "${local.secret_prefix}/db/endpoint"
    db_name            = "${local.secret_prefix}/db/name"
    log_group_app      = "${local.secret_prefix}/log-group/app"
  }

  app_port      = 8080
  alb_https_port = 8443
  db_port       = 3306

  # Subnet CIDRs derived from var.vpc_cidr (a /16). Reserves /24s in the /16
  # so each tier gets up to 4 AZs without renumbering.
  public_subnets   = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_app_cidr = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, 10 + i)]
  private_db_cidr  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, 20 + i)]
}

data "aws_availability_zones" "available" {
  state = "available"
}

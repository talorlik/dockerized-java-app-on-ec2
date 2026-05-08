###############################################################################
# Network foundation
#
# Three-tier VPC built from terraform-aws-modules/vpc/aws:
#   - Public subnets:        ALB + NAT gateways
#   - Private app subnets:   ASG instances
#   - Private DB subnets:    RDS subnet group
#
# Plus VPC endpoints so private nodes can reach SSM, Secrets Manager, ECR,
# CloudWatch Logs, and S3 without traversing the NAT for every call.
###############################################################################

module "vpc" {
  # checkov:skip=CKV_TF_1:source pinned via registry tag (~> 5.13). Commit-hash pinning rejected for upstream-maintained modules; CKV_TF_2 (tag pin) covers the supply-chain intent.
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs              = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets   = local.public_subnets
  private_subnets  = local.private_app_cidr
  database_subnets = local.private_db_cidr

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Flow logs (CloudWatch) for forensic visibility (FR-OPS-01).
  enable_flow_log                                 = true
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  flow_log_max_aggregation_interval               = 60
  flow_log_cloudwatch_log_group_retention_in_days = var.log_retention_days

  public_subnet_tags = {
    Tier                     = "public"
    "kubernetes.io/role/elb" = "1" # harmless tag, useful for any future EKS coexistence
  }
  private_subnet_tags = {
    Tier = "private-app"
  }
  database_subnet_tags = {
    Tier = "private-db"
  }

  tags = local.common_tags
}

# ----------------------------------------------------------------------------
# VPC Endpoints
# ----------------------------------------------------------------------------

# Endpoint security group: allow HTTPS from VPC CIDR.
resource "aws_security_group" "vpce" {
  name        = "${local.name_prefix}-vpce-sg"
  description = "Allow HTTPS from VPC to interface VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # The vpce SG is only attached to interface VPC endpoints, which never
  # initiate outbound traffic to anything beyond their parent VPC. Restrict
  # egress to the VPC CIDR (still on TCP/443) so checkov CKV_AWS_382 passes
  # and the SG's intent is explicit.
  egress {
    description = "HTTPS replies inside VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpce-sg" })
}

locals {
  interface_endpoints = [
    "ssm",
    "ssmmessages",
    "ec2messages",
    "secretsmanager",
    "logs",
    "monitoring",
    "ecr.api",
    "ecr.dkr",
  ]
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(local.interface_endpoints)

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpce-${replace(each.value, ".", "-")}" })
}

# S3 gateway endpoint - required for ECR layer pulls (ECR stores layers in S3)
# and for any direct S3 access (e.g. compose object).
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(module.vpc.private_route_table_ids, module.vpc.database_route_table_ids)

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpce-s3" })
}

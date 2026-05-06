###############################################################################
# RDS MySQL (private, Multi-AZ, encrypted)
#
# - Master password managed by RDS in Secrets Manager (rotated by AWS).
# - App user is created by Flyway with credentials from Secrets Manager.
# - Backups, deletion protection, performance insights, and slow-query logs
#   are enabled per TR-DB-001..008.
###############################################################################

resource "aws_db_parameter_group" "mysql" {
  name        = "${local.name_prefix}-mysql8"
  family      = "mysql8.0"
  description = "Custom MySQL 8.0 parameter group"

  # UTF-8 across the board
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_0900_ai_ci"
  }

  # Slow query logging
  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "immediate"
  }
  parameter {
    name         = "long_query_time"
    value        = "1"
    apply_method = "immediate"
  }
  parameter {
    name         = "log_output"
    value        = "FILE"
    apply_method = "immediate"
  }

  # Connection sizing - tune as load grows
  parameter {
    name         = "max_connections"
    value        = "200"
    apply_method = "pending-reboot"
  }

  tags = local.common_tags
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.10"

  identifier = "${local.name_prefix}-mysql"

  engine               = "mysql"
  engine_version       = var.rds_engine_version
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage_gb
  max_allocated_storage = var.rds_max_allocated_storage_gb
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.app_secrets.arn

  db_name  = var.db_name
  username = "dbadmin" # master user; password is RDS-managed below
  port     = local.db_port

  # RDS-managed master password in Secrets Manager (rotated by AWS).
  manage_master_user_password             = true
  master_user_secret_kms_key_id           = aws_kms_key.app_secrets.arn
  master_user_password_rotate_immediately = false

  multi_az               = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = module.vpc.database_subnet_group_name

  backup_retention_period          = 14
  backup_window                    = "03:00-04:00"
  maintenance_window               = "Sun:04:30-Sun:05:30"
  deletion_protection              = var.rds_deletion_protection
  delete_automated_backups         = var.rds_delete_automated_backups
  skip_final_snapshot              = var.rds_skip_final_snapshot
  final_snapshot_identifier_prefix = "${local.name_prefix}-mysql-final"

  # Use the AWS-managed default option group. Custom option groups are the
  # only kind that can wedge a destroy via retained snapshots/backups; we
  # have no MySQL options to set (everything tunable for our workload lives
  # in aws_db_parameter_group.mysql), so the default OG is sufficient and
  # cannot be lockup-blocked.
  create_db_option_group = false
  option_group_name      = "default:mysql-8-0"

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  monitoring_interval    = 60
  create_monitoring_role = true
  monitoring_role_name   = "${local.name_prefix}-rds-monitoring"

  # Use the parameter group we manage outside the module (above).
  parameter_group_name            = aws_db_parameter_group.mysql.name
  create_db_parameter_group       = false
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = local.common_tags
}

# Expose the DB endpoint to user-data via SSM (non-secret).
resource "aws_ssm_parameter" "db_endpoint" {
  name  = local.ssm_keys.db_endpoint
  type  = "String"
  value = module.rds.db_instance_address
}

resource "aws_ssm_parameter" "db_name" {
  name  = local.ssm_keys.db_name
  type  = "String"
  value = var.db_name
}

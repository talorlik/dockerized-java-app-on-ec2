###############################################################################
# Outputs - everything CI/operators need to know after apply.
###############################################################################

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS name. Route53 alias target."
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  value = module.alb.zone_id
}

output "asg_name" {
  description = "ASG name (for Instance Refresh in CI/CD)."
  value       = module.asg.autoscaling_group_name
}

output "ecr_backend_url" {
  value = aws_ecr_repository.this["backend"].repository_url
}

output "ecr_frontend_url" {
  value = aws_ecr_repository.this["frontend"].repository_url
}

output "ssm_backend_image_tag" {
  value = aws_ssm_parameter.backend_image_tag.name
}

output "ssm_frontend_image_tag" {
  value = aws_ssm_parameter.frontend_image_tag.name
}

output "ssm_release_id" {
  value = aws_ssm_parameter.release_id.name
}

output "ssm_compose_object" {
  value = aws_ssm_parameter.compose_object.name
}

output "rds_endpoint" {
  value     = module.rds.db_instance_address
  sensitive = false
}

output "rds_master_secret_arn" {
  description = "RDS-managed master credential secret ARN."
  value       = module.rds.db_instance_master_user_secret_arn
}

output "secret_db_app_user_arn" {
  value = aws_secretsmanager_secret.db_app_user.arn
}

output "secret_admin_arn" {
  value = aws_secretsmanager_secret.admin.arn
}

output "secret_jwt_arn" {
  value = aws_secretsmanager_secret.jwt.arn
}

output "secret_ses_arn" {
  value = aws_secretsmanager_secret.ses.arn
}

output "alarms_topic_arn" {
  value = aws_sns_topic.alarms.arn
}

output "app_url" {
  value = "https://${var.app_subdomain}"
}

output "ses_dkim_tokens" {
  description = "DKIM tokens (already published as CNAMEs in the domain hosted zone)."
  value       = aws_sesv2_email_identity.sender.dkim_signing_attributes[0].tokens
}

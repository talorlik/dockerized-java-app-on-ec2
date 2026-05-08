###############################################################################
# Inputs
###############################################################################

variable "aws_region" {
  description = "Deployment region."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project tag."
  type        = string
  default     = "java-app"
}

variable "environment" {
  description = "Environment tag."
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Owner tag for cost allocation."
  type        = string
  default     = "platform"
}

# ----------------------------------------------------------------------------
# Account model
# ----------------------------------------------------------------------------
variable "deployment_account_id" {
  description = "AWS account ID where infrastructure is deployed."
  type        = string
}

variable "domain_account_id" {
  description = "AWS account ID where the public Route53 hosted zone lives."
  type        = string
}

variable "domain_account_route53_role_arn" {
  description = <<EOT
Role ARN in the DOMAIN account that the deployment account is allowed to
assume in order to manage Route53 records (alias for the app, SES DKIM CNAMEs).
EOT
  type        = string
}

# ----------------------------------------------------------------------------
# Domain & TLS
# ----------------------------------------------------------------------------
variable "hosted_zone_id" {
  description = "Hosted zone ID for talorlik.com in the DOMAIN account."
  type        = string
}

variable "root_domain" {
  description = "Root domain registered in the DOMAIN account."
  type        = string
  default     = "talorlik.com"
}

variable "app_subdomain" {
  description = "Public app FQDN (must be a subdomain of root_domain)."
  type        = string
  default     = "java.talorlik.com"
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN in DEPLOYMENT account covering app_subdomain."
  type        = string
}

# ----------------------------------------------------------------------------
# Network
# ----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "Primary CIDR for the VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to span."
  type        = number
  default     = 2
}

# ----------------------------------------------------------------------------
# Compute
# ----------------------------------------------------------------------------
variable "instance_type" {
  description = "EC2 instance type for app nodes."
  type        = string
  default     = "t3.small"
}

variable "asg_min_size" {
  type    = number
  default = 2
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 6
}

variable "ubuntu_lts_codename" {
  description = <<EOT
Ubuntu LTS codename to resolve via Canonical's public SSM parameter
namespace (e.g. noble = 24.04). Switch to a newer codename once it is GA in
the target region (unverified - check Canonical's SSM listing).
EOT
  type        = string
  default     = "noble"
}

# ----------------------------------------------------------------------------
# Database
# ----------------------------------------------------------------------------
variable "rds_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "rds_allocated_storage_gb" {
  type    = number
  default = 50
}

variable "rds_max_allocated_storage_gb" {
  type    = number
  default = 200
}

variable "rds_engine_version" {
  description = "RDS MySQL engine version. 8.4 is the current LTS line; the bare major lets RDS pick the latest 8.4.x patch."
  type        = string
  default     = "8.4"
}

variable "db_name" {
  type    = string
  default = "javaapp"
}

variable "db_app_username" {
  type    = string
  default = "appuser"
}

# ----------------------------------------------------------------------------
# Application release pointers (initial values)
# ----------------------------------------------------------------------------
variable "initial_backend_image_tag" {
  description = <<EOT
Initial image tag stored in SSM. The CI/CD app-deploy workflow updates this
parameter on each release. Use 'bootstrap' to indicate no app has been
deployed yet.
EOT
  type        = string
  default     = "bootstrap"
}

variable "initial_frontend_image_tag" {
  type    = string
  default = "bootstrap"
}

# ----------------------------------------------------------------------------
# Email
# ----------------------------------------------------------------------------
variable "ses_sender_subdomain" {
  description = "SES sender identity (subdomain of root_domain)."
  type        = string
  default     = "java.talorlik.com"
}

variable "ses_from_address" {
  description = "RFC 5322 From address used for outbound transactional mail."
  type        = string
  default     = "no-reply@java.talorlik.com"
}

# ----------------------------------------------------------------------------
# Observability
# ----------------------------------------------------------------------------
variable "alarm_email" {
  description = "Optional email subscribed to the SNS alarm topic. Empty disables subscription."
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = <<EOT
CloudWatch Logs retention for application + VPC flow log groups.
Dev-only environment: defaulted to 1 day (the service minimum; sub-day
retention is not supported). Bump to 365+ for live use; the corresponding
checkov skip on aws_cloudwatch_log_group.app must also be removed in
that case.
EOT
  type        = number
  default     = 1
}

# ----------------------------------------------------------------------------
# WAF
# ----------------------------------------------------------------------------
variable "enable_waf" {
  type    = bool
  default = true
}

# ----------------------------------------------------------------------------
# Destroy-friendly dev defaults
#
# This stack is a development reference impl. Defaults below are tuned so a
# `infra-apply -> infra-destroy -> infra-apply` cycle never blocks on
# protected resources, retained snapshots, or non-empty buckets/repos.
#
# BEFORE GOING LIVE, flip every default in this section:
#   rds_deletion_protection      false -> true
#   rds_skip_final_snapshot      true  -> false
#   rds_delete_automated_backups true  -> false
#   alb_logs_force_destroy       true  -> false
#   alb_deletion_protection      false -> true
# (and remove the dev-only retention skips on aws_cloudwatch_log_group.app
#  / .waf, plus bump var.log_retention_days; see those resources.)
# ----------------------------------------------------------------------------
variable "rds_deletion_protection" {
  description = "Whether RDS deletion protection is enabled. Dev default: false."
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Skip the RDS final snapshot at destroy time. Dev default: true (no snapshot orphan to wedge re-apply)."
  type        = bool
  default     = true
}

variable "alb_logs_force_destroy" {
  description = "Force-destroy the ALB log bucket even if non-empty. Dev default: true."
  type        = bool
  default     = true
}

variable "rds_delete_automated_backups" {
  description = "Delete retained automated backups when the instance is destroyed. Dev default: true."
  type        = bool
  default     = true
}

variable "alb_deletion_protection" {
  description = "Whether the ALB carries deletion protection. Dev default: false so a clean `terraform destroy` doesn't need an out-of-band flip."
  type        = bool
  default     = false
}

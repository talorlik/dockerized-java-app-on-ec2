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
  description = "RDS MySQL engine version. 8.0 lets RDS choose the latest 8.0.x."
  type        = string
  default     = "8.0"
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
  type    = number
  default = 30
}

# ----------------------------------------------------------------------------
# WAF
# ----------------------------------------------------------------------------
variable "enable_waf" {
  type    = bool
  default = true
}

# ----------------------------------------------------------------------------
# Destroy-time overrides
#
# Kept safe by default. The infra-destroy workflow flips these via TF_VAR_* so
# that a single `terraform destroy` can tear the env down without manual
# pre-steps. Do not flip them in normal apply runs.
# ----------------------------------------------------------------------------
variable "rds_deletion_protection" {
  description = "Whether RDS deletion protection is enabled. Override to false at destroy time."
  type        = bool
  default     = true
}

variable "rds_skip_final_snapshot" {
  description = "Skip the RDS final snapshot at destroy time. Override to true at destroy time."
  type        = bool
  default     = false
}

variable "alb_logs_force_destroy" {
  description = "Force-destroy the ALB log bucket even if non-empty. Override to true at destroy time."
  type        = bool
  default     = false
}

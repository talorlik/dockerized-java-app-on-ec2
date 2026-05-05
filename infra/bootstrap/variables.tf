variable "aws_region" {
  description = "AWS region in which to create the Terraform state bucket."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Short project tag applied to all resources."
  type        = string
  default     = "java-app"
}

variable "owner" {
  description = "Owner tag applied to bootstrap resources."
  type        = string
  default     = "platform"
}

variable "state_bucket_name" {
  description = <<EOT
Globally-unique S3 bucket name for the Terraform state.
Recommended pattern: <project>-tfstate-<deployment_account_id>-<region>.
EOT
  type        = string
}

variable "kms_alias" {
  description = "Alias for the KMS key used to encrypt state."
  type        = string
  default     = "alias/java-app-tfstate"
}

variable "enable_access_logging" {
  description = "Whether to provision an access-log bucket and enable S3 access logs."
  type        = bool
  default     = true
}

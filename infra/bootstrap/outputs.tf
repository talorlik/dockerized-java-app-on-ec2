output "state_bucket_name" {
  description = "S3 bucket name to use in infra/envs/prod backend block."
  value       = aws_s3_bucket.tfstate.id
}

output "state_bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.tfstate.arn
}

output "state_kms_key_arn" {
  description = "KMS key ARN used for state encryption."
  value       = aws_kms_key.tfstate.arn
}

output "state_kms_key_alias" {
  description = "KMS key alias."
  value       = aws_kms_alias.tfstate.name
}

output "access_log_bucket_name" {
  description = "S3 access-log bucket name (null if disabled)."
  value       = try(aws_s3_bucket.access_logs[0].id, null)
}

output "backend_block_example" {
  description = "Drop this block into infra/envs/prod/backend.tf."
  value = <<EOT
terraform {
  backend "s3" {
    bucket       = "${aws_s3_bucket.tfstate.id}"
    key          = "java-app/prod/terraform.tfstate"
    region       = "${var.aws_region}"
    encrypt      = true
    kms_key_id   = "${aws_kms_key.tfstate.arn}"
    use_lockfile = true
  }
}
EOT
}

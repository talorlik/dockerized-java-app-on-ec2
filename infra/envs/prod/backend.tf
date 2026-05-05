###############################################################################
# Remote state backend.
#
# The bucket and KMS key are created by infra/bootstrap. Replace placeholders
# with the bootstrap outputs (or pass them via -backend-config).
#
# Native S3 locking is used (use_lockfile = true). DynamoDB is not required.
###############################################################################

terraform {
  backend "s3" {
    bucket       = "java-app-tfstate-260684397593-us-east-1"
    key          = "java-app/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:us-east-1:260684397593:key/4d06feee-1aea-4a51-9ecb-174775f82666"
    use_lockfile = true
  }
}

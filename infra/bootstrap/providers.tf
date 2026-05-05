# Default provider targets the DEPLOYMENT account.
# Bootstrap is run with credentials that already point at the deployment account
# (typically by the operator with admin access on first run).

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = "bootstrap"
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}

terraform {
  required_version = ">= 1.7.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    # Used by db_bootstrap.tf to package the appuser-bootstrap Lambda zip
    # at apply time without requiring an out-of-band build step.
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.6"
    }
  }
}

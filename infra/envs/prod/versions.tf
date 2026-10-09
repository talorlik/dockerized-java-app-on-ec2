terraform {
  required_version = "1.16.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.4.1"
    }
    # Used by db_bootstrap.tf to package the appuser-bootstrap Lambda zip
    # at apply time without requiring an out-of-band build step.
    archive = {
      source  = "hashicorp/archive"
      version = "2.8.1"
    }
  }
}

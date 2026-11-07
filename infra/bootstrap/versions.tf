# Pin tooling versions for the bootstrap module.
# Bootstrap creates the remote state bucket only - it intentionally uses
# local state (no backend block) since it must run before the backend exists.

terraform {
  required_version = "1.17.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}

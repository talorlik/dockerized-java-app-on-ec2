###############################################################################
# ECR repositories for backend and frontend.
#
# - Image scanning on push.
# - Tag immutability so a SHA tag can't be overwritten.
# - Lifecycle policy: keep latest 30 tagged images, expire untagged after 7d.
###############################################################################

locals {
  ecr_repos = {
    backend  = "${var.project}/backend"
    frontend = "${var.project}/frontend"
  }
}

resource "aws_ecr_repository" "this" {
  for_each             = local.ecr_repos
  name                 = each.value
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.app_secrets.arn
  }

  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 SHA-tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPatternList = ["sha-*", "v*"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = { type = "expire" }
      }
    ]
  })
}

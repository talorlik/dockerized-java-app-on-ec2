###############################################################################
# DB bootstrap - idempotent provisioning of the application MySQL user.
#
# Why this exists:
#   The RDS instance ships with only the master user (`dbadmin`). The
#   application connects as `appuser`, whose CREATE USER + GRANT cannot be
#   performed by Flyway because Flyway authenticates AS `appuser` (chicken/
#   egg). After every dev-cycle `terraform destroy` + `terraform apply` the
#   RDS instance is recreated empty-of-`appuser`, the backend container
#   crash-loops on `Access denied for user 'appuser'`, and the ASG flaps
#   until the user is provisioned out-of-band. See runbook RB-ASG-001
#   (docs/auxiliary/operations_guide/runbooks/2026-05-10_asg_flapping_investigation.md).
#
# How:
#   A small Python Lambda runs in the VPC, reads the RDS-managed master
#   secret and the app-user secret from Secrets Manager, and executes
#   idempotent DDL:
#
#     CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED WITH caching_sha2_password BY ?;
#     ALTER USER  'appuser'@'%' IDENTIFIED WITH caching_sha2_password BY ?;
#     GRANT ALL PRIVILEGES ON `javaapp`.* TO 'appuser'@'%';
#     FLUSH PRIVILEGES;
#
#   `terraform_data.db_bootstrap` invokes the Lambda whenever:
#     - the RDS resource id changes (replacement, e.g. dev-cycle re-apply), or
#     - the app-user secret version changes (manual rotation).
#
# Trade-off vs. data "aws_lambda_invocation":
#   That data source runs on every plan, which adds noise. terraform_data
#   with explicit triggers re-runs only on the events that actually require
#   the bootstrap to converge. Both are idempotent on the DB side; this
#   choice is purely about plan signal-to-noise.
#
# Connection security:
#   TLS to RDS without CA verification (ssl={"ssl": {}} in the Lambda).
#   Intra-VPC traffic to the RDS endpoint is the only viable path because
#   the RDS SG only accepts ingress from referenced SGs. Tighten to a CA
#   bundle if compliance requires explicit cert validation.
###############################################################################

# ----------------------------------------------------------------------------
# Network: dedicated SG for the bootstrap Lambda. Egress to RDS on 3306
# (referenced-SG rule), and HTTPS to AWS APIs (Secrets Manager VPCE).
# ----------------------------------------------------------------------------
resource "aws_security_group" "db_bootstrap_lambda" {
  # checkov:skip=CKV2_AWS_5:attached to aws_lambda_function.db_bootstrap.vpc_config; checkov cannot follow the SG ID through the Lambda VPC config.
  name        = "${local.name_prefix}-db-bootstrap-sg"
  description = "Lambda that bootstraps the appuser MySQL account after RDS is created."
  vpc_id      = module.vpc.vpc_id
  tags        = merge(local.common_tags, { Name = "${local.name_prefix}-db-bootstrap-sg" })
}

resource "aws_vpc_security_group_egress_rule" "db_bootstrap_to_rds" {
  security_group_id            = aws_security_group.db_bootstrap_lambda.id
  description                  = "MySQL egress to RDS"
  ip_protocol                  = "tcp"
  from_port                    = local.db_port
  to_port                      = local.db_port
  referenced_security_group_id = aws_security_group.rds.id
}

resource "aws_vpc_security_group_egress_rule" "db_bootstrap_https" {
  security_group_id = aws_security_group.db_bootstrap_lambda.id
  description       = "HTTPS to AWS APIs (Secrets Manager VPCE)"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_db_bootstrap" {
  security_group_id            = aws_security_group.rds.id
  description                  = "MySQL from db-bootstrap Lambda"
  ip_protocol                  = "tcp"
  from_port                    = local.db_port
  to_port                      = local.db_port
  referenced_security_group_id = aws_security_group.db_bootstrap_lambda.id
}

# ----------------------------------------------------------------------------
# IAM
# ----------------------------------------------------------------------------
data "aws_iam_policy_document" "db_bootstrap_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "db_bootstrap_lambda" {
  name               = "${local.name_prefix}-db-bootstrap-lambda"
  assume_role_policy = data.aws_iam_policy_document.db_bootstrap_assume.json
  tags               = local.common_tags
}

# Required for VPC-attached Lambda: ENI create/delete + log writes.
resource "aws_iam_role_policy_attachment" "db_bootstrap_vpc_exec" {
  role       = aws_iam_role.db_bootstrap_lambda.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "db_bootstrap_inline" {
  # Read both DB credential secrets.
  statement {
    sid    = "ReadDbSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      module.rds.db_instance_master_user_secret_arn,
      aws_secretsmanager_secret.db_app_user.arn,
    ]
  }

  # Decrypt the secrets above (both are encrypted with the app-secrets CMK
  # per rds.tf:87 and secrets.tf:104).
  statement {
    sid       = "DecryptSecrets"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = [aws_kms_key.app_secrets.arn]
  }
}

resource "aws_iam_policy" "db_bootstrap_inline" {
  name   = "${local.name_prefix}-db-bootstrap-inline"
  policy = data.aws_iam_policy_document.db_bootstrap_inline.json
}

resource "aws_iam_role_policy_attachment" "db_bootstrap_inline" {
  role       = aws_iam_role.db_bootstrap_lambda.name
  policy_arn = aws_iam_policy.db_bootstrap_inline.arn
}

# ----------------------------------------------------------------------------
# Lambda package
# ----------------------------------------------------------------------------
data "archive_file" "db_bootstrap" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/db_bootstrap"
  output_path = "${path.module}/.terraform/tmp/db_bootstrap.zip"

  # Excludes any pre-existing zip alongside the source dir to prevent
  # archive_file from packaging its own output if Terraform is re-run with
  # the output path inside source_dir (it isn't here, but defensive).
  excludes = ["__pycache__", "*.pyc"]
}

resource "aws_lambda_function" "db_bootstrap" {
  # checkov:skip=CKV_AWS_115:reserved concurrency intentionally unset; the function is invoked once per terraform_data trigger event, not by a high-throughput consumer.
  # checkov:skip=CKV_AWS_116:DLQ intentionally unset; Lambda errors propagate to terraform_data.local-exec and surface in the apply log.
  # checkov:skip=CKV_AWS_117:VPC config IS set (vpc_config block below); checkov sometimes mis-parses inline VPC config blocks.
  # checkov:skip=CKV_AWS_173:env vars are non-sensitive identifiers (host, port, db name, secret ARNs); secret VALUES are fetched at runtime.
  # checkov:skip=CKV_AWS_272:code-signing not enforced in dev; revisit alongside enabling AWS Signer for the deployment account.
  function_name = "${local.name_prefix}-db-bootstrap"
  description   = "Idempotent CREATE USER + GRANT for the application MySQL user."

  role             = aws_iam_role.db_bootstrap_lambda.arn
  filename         = data.archive_file.db_bootstrap.output_path
  source_code_hash = data.archive_file.db_bootstrap.output_base64sha256

  runtime     = "python3.12"
  handler     = "main.handler"
  timeout     = 60
  memory_size = 256

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.db_bootstrap_lambda.id]
  }

  environment {
    variables = {
      DB_HOST            = module.rds.db_instance_address
      DB_PORT            = tostring(local.db_port)
      DB_NAME            = var.db_name
      APP_USER           = var.db_app_username
      MASTER_SECRET_ARN  = module.rds.db_instance_master_user_secret_arn
      APPUSER_SECRET_ARN = aws_secretsmanager_secret.db_app_user.arn
    }
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.db_bootstrap_vpc_exec,
    aws_iam_role_policy_attachment.db_bootstrap_inline,
  ]
}

# ----------------------------------------------------------------------------
# Invocation orchestrator
#
# terraform_data is a no-op resource that re-runs its provisioner only when
# triggers_replace changes. We trigger on:
#   - module.rds.db_instance_resource_id  -> RDS replacement (dev re-apply).
#   - aws_secretsmanager_secret_version.db_app_user.version_id -> rotation.
#   - aws_lambda_function.db_bootstrap.source_code_hash -> code change.
#
# The provisioner shells out to `aws lambda invoke`, then fails the apply
# if the function returned an error or non-200 status. This surfaces DB
# bootstrap problems at apply time instead of leaving a broken stack
# behind a green plan/apply.
# ----------------------------------------------------------------------------
resource "terraform_data" "db_bootstrap" {
  triggers_replace = {
    rds_id            = module.rds.db_instance_resource_id
    app_secret_ver    = aws_secretsmanager_secret_version.db_app_user.version_id
    lambda_code_hash  = aws_lambda_function.db_bootstrap.source_code_hash
    lambda_env_master = module.rds.db_instance_master_user_secret_arn
    lambda_env_app    = aws_secretsmanager_secret.db_app_user.arn
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      OUT=$(mktemp -t db_bootstrap_out.XXXXXX.json)
      trap 'rm -f "$OUT"' EXIT
      aws lambda invoke \
        --region ${var.aws_region} \
        --function-name ${aws_lambda_function.db_bootstrap.function_name} \
        --invocation-type RequestResponse \
        --cli-binary-format raw-in-base64-out \
        --payload '{}' \
        "$OUT" >/dev/null
      cat "$OUT"
      echo
      python3 -c '
      import json, sys
      data=json.load(open(sys.argv[1]))
      if not isinstance(data, dict) or data.get("status") != "ok":
          print("db_bootstrap returned unexpected payload:", data, file=sys.stderr)
          sys.exit(1)
      ' "$OUT"
    EOT
  }

  depends_on = [
    aws_lambda_function.db_bootstrap,
    aws_iam_role_policy_attachment.db_bootstrap_inline,
    aws_iam_role_policy_attachment.db_bootstrap_vpc_exec,
    aws_vpc_security_group_egress_rule.db_bootstrap_to_rds,
    aws_vpc_security_group_egress_rule.db_bootstrap_https,
    aws_vpc_security_group_ingress_rule.rds_from_db_bootstrap,
    module.rds,
  ]
}

# ----------------------------------------------------------------------------
# Outputs (operator-facing)
# ----------------------------------------------------------------------------
output "db_bootstrap_lambda_name" {
  description = "Name of the Lambda that provisions the appuser MySQL account. Manually re-trigger with: aws lambda invoke --function-name <name> /tmp/out.json && cat /tmp/out.json"
  value       = aws_lambda_function.db_bootstrap.function_name
}

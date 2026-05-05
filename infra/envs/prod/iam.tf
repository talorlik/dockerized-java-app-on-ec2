###############################################################################
# IAM
#
# Instance role used by EC2 app nodes. Permissions:
#   - Read approved secrets and SSM parameters.
#   - Pull from ECR.
#   - Write logs/metrics to CloudWatch.
#   - Send mail through SES from the approved identity.
#   - SSM Session Manager (no SSH).
###############################################################################

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_instance" {
  name               = "${local.name_prefix}-app-instance"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = local.common_tags
}

# AWS-managed: SSM core (Session Manager).
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.app_instance.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# AWS-managed: CloudWatch Agent server policy.
resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.app_instance.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# AWS-managed: ECR read-only.
resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.app_instance.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Inline: scoped read of approved secrets, SSM params, and SES send from
# the approved identity only.
data "aws_iam_policy_document" "app_inline" {
  # Secrets Manager read for known ARNs.
  statement {
    sid    = "ReadAppSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      aws_secretsmanager_secret.db_app_user.arn,
      aws_secretsmanager_secret.admin.arn,
      aws_secretsmanager_secret.jwt.arn,
      aws_secretsmanager_secret.ses.arn,
      module.rds.db_instance_master_user_secret_arn,
    ]
  }

  # SSM Parameter Store reads under the project namespace.
  statement {
    sid    = "ReadAppSsmParams"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = ["arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${var.deployment_account_id}:parameter${local.secret_prefix}/*"]
  }

  # KMS decrypt for the secrets/parameters CMK.
  statement {
    sid       = "DecryptAppCmk"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = [aws_kms_key.app_secrets.arn]
  }

  # CloudWatch Logs PutLog from app + Docker.
  statement {
    sid    = "PutCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
    ]
    resources = ["*"]
  }

  # SES: send only from the approved identity.
  statement {
    sid    = "SesSendFromApprovedIdentity"
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ses:${var.aws_region}:${var.deployment_account_id}:identity/${var.ses_sender_subdomain}",
    ]
  }

  # ECR: GetAuthorizationToken is account-scoped (must be *).
  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "app_inline" {
  name   = "${local.name_prefix}-app-inline"
  policy = data.aws_iam_policy_document.app_inline.json
}

resource "aws_iam_role_policy_attachment" "app_inline" {
  role       = aws_iam_role.app_instance.name
  policy_arn = aws_iam_policy.app_inline.arn
}

resource "aws_iam_instance_profile" "app" {
  name = "${local.name_prefix}-app-instance"
  role = aws_iam_role.app_instance.name
}

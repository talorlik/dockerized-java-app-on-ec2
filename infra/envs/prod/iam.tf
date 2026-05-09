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
#
# Per-statement CKV_AWS_111 / CKV_AWS_356 notes:
#   - Writes are now scoped to the project's log groups (PutCloudWatchLogs).
#   - The remaining "*" resources (DescribeLogGroups, GetAuthorizationToken,
#     SetInstanceHealth) have no resource-level scoping in IAM; the
#     suppression below documents that.
data "aws_iam_policy_document" "app_inline" {
  # checkov:skip=CKV_AWS_356:Remaining wildcard resources are on actions that have no resource-level scoping in IAM (logs:DescribeLogGroups, ecr:GetAuthorizationToken, autoscaling:SetInstanceHealth).
  # checkov:skip=CKV_AWS_111:Same as above; the write actions logs:Create*/PutLogEvents are scoped to the app log group ARN. SetInstanceHealth is a write action that AWS does not resource-scope.

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

  # CloudWatch Logs writes scoped to the app log group (group + streams).
  statement {
    sid    = "PutCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      aws_cloudwatch_log_group.app.arn,
      "${aws_cloudwatch_log_group.app.arn}:*",
    ]
  }

  # logs:DescribeLogGroups has no resource-level scoping in IAM.
  statement {
    sid       = "DescribeLogGroupsAccountWide"
    effect    = "Allow"
    actions   = ["logs:DescribeLogGroups"]
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

  # S3 read of the published docker-compose object. The bucket is created
  # out-of-band by .github/workflows/infra-apply.yml using the deterministic
  # name "${var.project}-${var.environment}-config-${var.deployment_account_id}";
  # user-data resolves the s3:// URI from SSM /java-app/prod/compose-object and
  # runs `aws s3 cp` at boot. Without this grant the HEAD on the object returns
  # 403, user-data fails, the ERR trap calls self_unhealthy with
  # --no-should-respect-grace-period, and the ASG flaps every ~115s. The object
  # is encrypted with aws_kms_key.app_secrets; KMS Decrypt is granted in the
  # DecryptAppCmk statement above. See runbook RB-ASG-001
  # (docs/auxiliary/operations_guide/runbooks/2026-05-10_asg_flapping_investigation.md).
  statement {
    sid    = "ReadComposeObject"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.project}-${var.environment}-config-${var.deployment_account_id}/docker-compose.prod.yml",
    ]
  }

  # Allow the user-data boot script to mark its own instance Unhealthy if
  # the actuator never returns UP within the boot deadline. Without this
  # the box would linger as a black hole behind the ALB until the grace
  # period expires; with it the ASG replaces it immediately.
  # SetInstanceHealth has no resource-level scoping in IAM, so this must
  # be Resource:* and is gated by the aws:SourceArn condition matching the
  # caller's own instance ARN, scoping it in practice to instances of THIS
  # ASG even if the role were ever reused elsewhere.
  statement {
    sid       = "SelfMarkInstanceUnhealthy"
    effect    = "Allow"
    actions   = ["autoscaling:SetInstanceHealth"]
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

###############################################################################
# AWS Service-Linked Roles
#
# EC2 Auto Scaling and Elastic Load Balancing both rely on account-scoped
# SLRs. They are pre-created out-of-band by the GitHub Actions workflows
# (.github/workflows/infra-apply.yml and infra-destroy.yml) using
# `aws iam create-service-linked-role` before `terraform init`. They are
# intentionally not managed by Terraform: they are account-wide singletons,
# never deleted by this stack, and pre-creation in the workflow eliminates
# the original race against ASG capacity validation without import blocks
# or removed-blocks gymnastics.
###############################################################################

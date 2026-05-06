###############################################################################
# Launch Template + Auto Scaling Group
#
# Latest Ubuntu LTS resolved at apply time via Canonical's public SSM
# parameter namespace. IMDSv2 required, encrypted EBS, no SSH ingress.
###############################################################################

# Canonical publishes Ubuntu AMI IDs at predictable SSM paths under
# /aws/service/canonical/ubuntu/server/<codename>/stable/current/amd64/hvm/ebs-gp3/ami-id
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/${var.ubuntu_lts_codename}/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# CloudWatch log group consumed by the CloudWatch agent on the instance.
resource "aws_cloudwatch_log_group" "app" {
  name              = "/${var.project}/${var.environment}/app"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.app_secrets.arn
  tags              = local.common_tags
}

resource "aws_ssm_parameter" "log_group_app" {
  name  = local.ssm_keys.log_group_app
  type  = "String"
  value = aws_cloudwatch_log_group.app.name
}

# ----------------------------------------------------------------------------
# User-data script
#
# Renders a templated bash script that installs Docker + Compose + CloudWatch
# Agent, fetches release metadata from SSM and the compose file from S3,
# performs ECR auth, then `docker compose up -d`.
# ----------------------------------------------------------------------------
locals {
  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tpl", {
    aws_region         = var.aws_region
    ssm_compose_object = local.ssm_keys.compose_object
    ssm_backend_tag    = local.ssm_keys.backend_image_tag
    ssm_frontend_tag   = local.ssm_keys.frontend_image_tag
    ssm_release_id     = local.ssm_keys.release_id
    ssm_db_endpoint    = local.ssm_keys.db_endpoint
    ssm_db_name        = local.ssm_keys.db_name
    secret_db_app_user = aws_secretsmanager_secret.db_app_user.name
    secret_admin       = aws_secretsmanager_secret.admin.name
    secret_jwt         = aws_secretsmanager_secret.jwt.name
    secret_ses         = aws_secretsmanager_secret.ses.name
    backend_repo_url   = aws_ecr_repository.this["backend"].repository_url
    frontend_repo_url  = aws_ecr_repository.this["frontend"].repository_url
    log_group_name     = aws_cloudwatch_log_group.app.name
    deployment_account = var.deployment_account_id
    app_subdomain      = var.app_subdomain
  }))
}

# ----------------------------------------------------------------------------
# Launch Template + ASG
# ----------------------------------------------------------------------------
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 7.7"

  name = "${local.name_prefix}-asg"

  min_size            = var.asg_min_size
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "ELB"

  # First boot on a fresh Ubuntu image runs apt + AWS CLI v2 install + CWA
  # install + ECR pull + Spring Boot startup. On t3.small with cold caches
  # this regularly takes 4-7 min. 300s grace was racing the slowest path
  # and producing one unhealthy instance per refresh; 600s gives Spring
  # Boot plus the actuator probe enough headroom.
  health_check_grace_period = 600

  # Attach to ALB target group created in alb.tf.
  target_group_arns = [module.alb.target_groups["app"].arn]

  # Launch Template
  create_launch_template = true
  launch_template_name   = "${local.name_prefix}-lt"
  update_default_version = true

  image_id      = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = var.instance_type
  user_data     = local.user_data

  iam_instance_profile_name = aws_iam_instance_profile.app.name

  security_groups = [aws_security_group.app.id]

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 required
    http_put_response_hop_limit = 2          # 2 = container-friendly (Docker bridge)
    instance_metadata_tags      = "enabled"
  }

  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      ebs = {
        volume_size           = 30
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    }
  ]

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = merge(local.common_tags, { Name = "${local.name_prefix}-app" })
    },
    {
      resource_type = "volume"
      tags          = local.common_tags
    }
  ]

  # Target tracking on ALB request count per target.
  scaling_policies = {
    request_count = {
      policy_type = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ALBRequestCountPerTarget"
          resource_label         = "${module.alb.arn_suffix}/${module.alb.target_groups["app"].arn_suffix}"
        }
        target_value = 200
      }
    }
    cpu = {
      policy_type = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 60
      }
    }
  }

  # Instance refresh: launch-before-terminate posture (min_healthy=100).
  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 100
      max_healthy_percentage = 200
      # Match health_check_grace_period; warmup of 180s undercounts a cold
      # boot and starts pre-tracking metrics on a not-yet-ready instance.
      instance_warmup = 300
      auto_rollback   = true
    }
    triggers = ["tag"]
  }

  enabled_metrics = [
    "GroupInServiceInstances",
    "GroupDesiredCapacity",
    "GroupTotalInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
  ]

  tags = local.common_tags
}

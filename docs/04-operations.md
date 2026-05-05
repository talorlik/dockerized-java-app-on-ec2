# 04 - Operations runbook

## Logs

- App + Docker + Nginx + cloud-init: CloudWatch log group `/java-app/prod/app`.
- VPC flow logs: `flow_log_cloudwatch_log_group` created by the VPC module.
- ALB access logs: `s3://java-app-prod-alb-logs-<account>/AWSLogs/<account>/...`.
- RDS error/general/slowquery: exported to CloudWatch by RDS.

## Dashboards

- `java-app-prod-main` includes ALB request/5xx, ALB latency, ASG capacity,
  RDS CPU/connections/storage.

## Alarms

| Alarm name                          | Threshold              |
| ----------------------------------- | ---------------------- |
| `java-app-prod-alb-5xx`             | sum > 10 / 1m for 2m   |
| `java-app-prod-alb-unhealthy-targets` | > 0 for 2m            |
| `java-app-prod-rds-cpu`             | > 80% for 5m           |
| `java-app-prod-rds-free-storage`    | < 5 GiB for 10m        |
| `java-app-prod-rds-connections`     | > 150 for 5m           |
| `java-app-prod-ec2-disk`            | > 85% for 3m           |
| EventBridge -> SNS                  | ASG instance refresh failed/cancelled |

All actions go to SNS topic `java-app-prod-alarms`. Subscribe an email by
setting `var.alarm_email` and re-applying.

## Access an instance

```bash
INSTANCE=$(aws ec2 describe-instances \
  --filters "Name=tag:aws:autoscaling:groupName,Values=java-app-prod-asg" "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].InstanceId' --output text | awk '{print $1}')
aws ssm start-session --target $INSTANCE
```

No SSH ingress is configured. Session Manager is the only access path.

## Restart app on a node

```bash
sudo -i
cd /opt/java-app
docker compose --env-file /opt/java-app/.env restart
```

## Force a release rollover

```bash
gh workflow run app-deploy.yml
```

Or manually:

```bash
aws ssm put-parameter --name /java-app/prod/backend-image-tag  --type String --overwrite --value sha-XXXX
aws ssm put-parameter --name /java-app/prod/frontend-image-tag --type String --overwrite --value sha-XXXX
aws ssm put-parameter --name /java-app/prod/release-id         --type String --overwrite --value "<rid>"

aws autoscaling start-instance-refresh \
  --auto-scaling-group-name java-app-prod-asg \
  --preferences '{"MinHealthyPercentage":100,"MaxHealthyPercentage":200,"InstanceWarmup":180,"AutoRollback":true}'
```

## DB access

App connects with the least-privilege user from `/java-app/prod/db/app-user`.
Operators use the master credential from the RDS-managed master secret only
for one-off admin tasks; never bake the master credential into config.

## SES sandbox

Until production access is granted, SES will only deliver to verified
recipients. Verify a test recipient address in the SES console for early
validation.

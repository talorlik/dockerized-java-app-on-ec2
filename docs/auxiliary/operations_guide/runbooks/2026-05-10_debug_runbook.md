# Runbook - Debug commands for project key elements

- ID: `RB-DEBUG-001`
- Created: 2026-05-10
- Scope: read-mostly debug commands for every layer of this stack -
  local backend (Spring Boot/Maven/Flyway), local Docker stack, frontend
  (Nginx), Terraform/state, AWS data plane (ALB, ASG/EC2, RDS, ECR,
  Secrets Manager, Route53, ACM, WAF, SES, SSM, CloudWatch),
  GitHub Actions/OIDC, MySQL 8.4 LTS post-upgrade checks, static analysis
  (tflint/checkov/tfsec), Playwright E2E.
- Hard rules echoed from `CLAUDE.md` section 10:
  - No `terraform apply` or `terraform destroy` from agent context.
  - No `latest` tag at runtime. SHA-pinned only.
  - No SSH ingress on EC2. Use SSM Session Manager.
  - No IMDSv2 disable. No public RDS.
  - No edits to applied Flyway migrations.
- Conventions used below:
  - `<...>` = placeholder you fill in.
  - `# mutating` flags any state-changing command.
  - Region is `us-east-1` unless overridden via `AWS_REGION`.
  - Account split: DEPLOYMENT (most resources), DOMAIN (Route53). Cross
    account calls assume the DNS role.

## 0. Pre-flight - identity, region, role

```bash
# Verify caller, region, and assumed role.
aws sts get-caller-identity
aws configure list
echo "AWS_REGION=${AWS_REGION:-us-east-1}"

# Confirm OIDC provider exists in DEPLOYMENT account (for GH Actions).
aws iam list-open-id-connect-providers \
  --query 'OpenIDConnectProviderList[].Arn'

# DEPLOYMENT github-role trust policy (sanity check).
aws iam get-role --role-name github-role \
  --query 'Role.AssumeRolePolicyDocument'

# DOMAIN role chained-assume from DEPLOYMENT (run from DEPLOYMENT context).
aws sts assume-role \
  --role-arn "arn:aws:iam::<DOMAIN_ACCOUNT_ID>:role/route53-dns-manager-role" \
  --role-session-name debug-session \
  --query 'Credentials.{ak:AccessKeyId,exp:Expiration}'
```

## 1. Backend (Spring Boot 3.5.0, Java 21, Maven)

### 1.1 Build and tests

```bash
cd app/backend
chmod +x ./mvnw

# Quick compile check.
./mvnw -B -ntp -DskipTests compile

# Unit tests only.
./mvnw -B -ntp test

# Full verify (Failsafe + Testcontainers MySQL).
./mvnw -B -ntp verify

# Run a single test class or method.
./mvnw -B -ntp -Dtest=PasswordPolicyTest test
./mvnw -B -ntp -Dtest=PasswordPolicyTest#rejects_short_password test

# Resolve effective dependency tree (find version conflicts).
./mvnw -B -ntp dependency:tree -Dverbose | tee /tmp/dep_tree.txt

# Show effective POM (after parent + property resolution).
./mvnw -B -ntp help:effective-pom -Doutput=/tmp/effective-pom.xml

# Inspect Spring Boot starter pinned versions.
./mvnw -B -ntp dependency:tree | grep -E 'spring-boot|jjwt|bucket4j|aws-sdk'
```

### 1.2 Local run, JVM introspection, heap

```bash
# Run the boot jar directly (after `package`).
java -jar app/backend/target/*.jar \
  --spring.profiles.active=local

# Enable verbose Flyway and SQL logs at runtime.
java \
  -Dlogging.level.org.flywaydb=DEBUG \
  -Dlogging.level.org.hibernate.SQL=DEBUG \
  -Dlogging.level.org.hibernate.type.descriptor.sql=TRACE \
  -jar app/backend/target/*.jar

# Live JVM diagnostics (replace <PID>).
jps -lvm
jcmd <PID> VM.version
jcmd <PID> VM.flags
jcmd <PID> Thread.print > /tmp/threads.txt
jcmd <PID> GC.heap_info
jcmd <PID> GC.class_histogram | head -50

# Heap dump (writes inside the JVM working dir).
jcmd <PID> GC.heap_dump /tmp/heap_$(date +%s).hprof   # mutating disk write

# Async-profiler style sampling (if installed).
jcmd <PID> JFR.start name=debug duration=60s filename=/tmp/debug.jfr
jcmd <PID> JFR.dump name=debug filename=/tmp/debug.jfr
jcmd <PID> JFR.stop name=debug
```

### 1.3 Actuator endpoints (local)

```bash
curl -fsS http://localhost:8080/actuator/health | jq
curl -fsS http://localhost:8080/actuator/info | jq
curl -fsS http://localhost:8080/actuator/env | jq '.propertySources[].name'
curl -fsS http://localhost:8080/actuator/metrics | jq '.names[]' | head -40
curl -fsS "http://localhost:8080/actuator/metrics/jvm.memory.used" | jq
curl -fsS http://localhost:8080/actuator/loggers | jq '.loggers | to_entries[:20]'
```

### 1.4 Flyway state

```bash
# Inside the running container or local DB:
mysql -u <user> -p -h <host> <db> -e "SELECT version, description, success, installed_on FROM flyway_schema_history ORDER BY installed_rank;"

# From Maven (uses JDBC URL from application config).
./mvnw -B -ntp -pl . flyway:info
./mvnw -B -ntp -pl . flyway:validate
# `flyway:repair` is mutating; only run after a failed migration is fixed:
./mvnw -B -ntp -pl . flyway:repair        # mutating
```

## 2. Frontend (Nginx static site)

```bash
# Validate Nginx config inside the container image.
docker build -t frontend-debug app/frontend
docker run --rm frontend-debug nginx -t
docker run --rm frontend-debug nginx -T | head -120   # full effective config

# Curl through the running compose stack.
curl -fsS -I http://localhost:8080/
curl -fsS -I http://localhost:8080/api/actuator/health

# Inspect served headers and CSP.
curl -sS -D - -o /dev/null http://localhost:8080/
```

## 3. Docker / Compose

### 3.1 Local stack (with MySQL)

```bash
cd app/docker

# Validate compose file resolution (env interpolation, image refs).
docker compose -f docker-compose.local.yml config
docker compose -f docker-compose.local.yml config --services
docker compose -f docker-compose.local.yml config --hash '*'

# Bring stack up, follow logs.
docker compose -f docker-compose.local.yml up --build         # mutating
docker compose -f docker-compose.local.yml logs -f --tail=200

# Service status, processes, exit codes.
docker compose -f docker-compose.local.yml ps
docker compose -f docker-compose.local.yml top

# Exec into a service.
docker compose -f docker-compose.local.yml exec backend bash
docker compose -f docker-compose.local.yml exec mysql mysql -uroot -p

# Tear down + volumes (full reset).
docker compose -f docker-compose.local.yml down -v            # mutating
```

### 3.2 Prod-shape stack

```bash
cd app/docker
docker compose -f docker-compose.prod.yml config
docker compose -f docker-compose.prod.yml config --resolve-image-digests
```

### 3.3 Image-level debug

```bash
# Layer audit.
docker history --no-trunc <repo>/<image>:<sha>
docker inspect <repo>/<image>:<sha> | jq '.[0].Config'

# Run a one-off shell against a built image.
docker run --rm -it --entrypoint /bin/sh <repo>/<image>:<sha>

# View labels (useful for build-info traceability).
docker inspect <repo>/<image>:<sha> --format '{{json .Config.Labels}}' | jq
```

## 4. Terraform - state, plan, lint

Per CLAUDE.md, never `apply` or `destroy` from agent context. The
DynamoDB lock table is not used; locking is native S3 (`use_lockfile = true`).

### 4.1 Plan-only flow

```bash
cd infra/envs/prod

terraform fmt -recursive -check
terraform validate
terraform init -upgrade=false -reconfigure
terraform plan -var-file=terraform.tfvars -out=/tmp/tf.plan
terraform show -json /tmp/tf.plan | jq '.resource_changes[] | {addr:.address, action:.change.actions}'
```

### 4.2 State inspection

```bash
terraform state list
terraform state show 'module.alb.aws_lb.this[0]'
terraform state show 'module.rds.aws_db_instance.this[0]'

# Refresh-only plan (detect drift without changing config).
terraform plan -refresh-only -var-file=terraform.tfvars

# Targeted plan during triage.
terraform plan -var-file=terraform.tfvars -target='module.asg'
```

### 4.3 S3 backend + native lockfile

```bash
# Inspect the backend config used.
cat backend.tf

# Confirm the state object exists.
aws s3api head-object \
  --bucket <state_bucket> \
  --key <prefix>/terraform.tfstate

# Confirm a stale `.tflock` is not blocking new runs (S3 native locking).
aws s3api head-object \
  --bucket <state_bucket> \
  --key <prefix>/terraform.tfstate.tflock 2>/dev/null \
  && echo "lock present" || echo "no lock"

# Force-unlock requires the lock ID printed by Terraform; only use after
# verifying no concurrent run exists:
terraform force-unlock <LOCK_ID>                              # mutating
```

### 4.4 Static analysis

```bash
tflint --init
tflint --recursive --color

checkov -d infra/envs/prod --quiet --compact
checkov -d infra/envs/prod --check CKV_AWS_8,CKV_AWS_24

tfsec infra/envs/prod --soft-fail=false --concise-output
```

## 5. AWS - networking and edge

### 5.1 ALB, target groups, listeners

```bash
# Find the ALB and target group ARNs.
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?contains(LoadBalancerName, `java-app`)].[LoadBalancerName,DNSName,LoadBalancerArn]' \
  --output table

LB_ARN=$(aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?contains(LoadBalancerName, `java-app`)].LoadBalancerArn' \
  --output text)

aws elbv2 describe-listeners --load-balancer-arn "$LB_ARN"
aws elbv2 describe-rules --listener-arn <listener_arn>

TG_ARN=$(aws elbv2 describe-target-groups \
  --load-balancer-arn "$LB_ARN" \
  --query 'TargetGroups[0].TargetGroupArn' --output text)

# Target health (this is the most common debug call).
aws elbv2 describe-target-health --target-group-arn "$TG_ARN" \
  --query 'TargetHealthDescriptions[].{id:Target.Id,port:Target.Port,state:TargetHealth.State,reason:TargetHealth.Reason,desc:TargetHealth.Description}' \
  --output table

# Health check definition (path, interval, thresholds, port).
aws elbv2 describe-target-groups --target-group-arns "$TG_ARN" \
  --query 'TargetGroups[0].{Path:HealthCheckPath,Port:HealthCheckPort,Proto:HealthCheckProtocol,Interval:HealthCheckIntervalSeconds,Timeout:HealthCheckTimeoutSeconds,Healthy:HealthyThresholdCount,Unhealthy:UnhealthyThresholdCount,Matcher:Matcher.HttpCode}'
```

### 5.2 Smoke through the ALB (public)

```bash
DOMAIN=java.talorlik.com

# 80 -> 443 redirect.
curl -sS -o /dev/null -D - http://$DOMAIN/ | head -5

# HTTPS health endpoint.
curl -fsS https://$DOMAIN/actuator/health | jq

# Negotiated TLS (verify ACM cert chain + SNI).
echo | openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```

### 5.3 Route53, ACM

```bash
# Hosted zone (DOMAIN account, via assumed role).
aws route53 list-hosted-zones-by-name --dns-name talorlik.com \
  --query 'HostedZones[].{Id:Id,Name:Name}'

aws route53 list-resource-record-sets \
  --hosted-zone-id <zone_id> \
  --query "ResourceRecordSets[?Name=='java.talorlik.com.']"

# ACM cert (DEPLOYMENT account).
aws acm describe-certificate --certificate-arn <acm_arn> \
  --query 'Certificate.{Status:Status,Domain:DomainName,SAN:SubjectAlternativeNames,InUse:InUseBy,Renewal:RenewalSummary.RenewalStatus,NotAfter:NotAfter}'
```

### 5.4 WAF

```bash
WEB_ACL_ARN=$(aws wafv2 list-web-acls --scope REGIONAL \
  --query 'WebACLs[?contains(Name, `java-app`)].ARN' --output text)

aws wafv2 get-web-acl --scope REGIONAL \
  --id <id> --name <name> \
  --query 'WebACL.Rules[].{Name:Name,Priority:Priority,Action:Action}'

# Blocked / sampled requests in the last 3 hours.
aws wafv2 get-sampled-requests \
  --scope REGIONAL \
  --web-acl-arn "$WEB_ACL_ARN" \
  --rule-metric-name <rule_metric> \
  --time-window "StartTime=$(date -u -v-3H +%FT%TZ),EndTime=$(date -u +%FT%TZ)" \
  --max-items 50
```

## 6. AWS - compute (EC2, ASG, SSM)

### 6.1 ASG state

```bash
aws autoscaling describe-auto-scaling-groups \
  --query 'AutoScalingGroups[?contains(AutoScalingGroupName, `java-app`)].[AutoScalingGroupName,DesiredCapacity,MinSize,MaxSize,HealthCheckType,HealthCheckGracePeriod]' \
  --output table

aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name <asg_name> --max-items 10 \
  --query 'Activities[].{Time:StartTime,Status:StatusCode,Cause:Cause}' --output table

# Instance refresh history (last refresh status).
aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name <asg_name> --max-records 5 \
  --query 'InstanceRefreshes[].{Id:InstanceRefreshId,Status:Status,Pct:PercentageComplete,Started:StartTime,End:EndTime}' --output table

# Launch template + version pointer.
aws autoscaling describe-launch-configurations 2>/dev/null
aws ec2 describe-launch-templates \
  --filters Name=tag:Name,Values=java-app-* \
  --query 'LaunchTemplates[].{Name:LaunchTemplateName,Default:DefaultVersionNumber,Latest:LatestVersionNumber}'
aws ec2 describe-launch-template-versions \
  --launch-template-id <lt_id> --versions '$Latest' \
  --query 'LaunchTemplateVersions[0].LaunchTemplateData.UserData' --output text \
  | base64 -d | head -80
```

### 6.2 Instance debug via SSM (no SSH)

```bash
# List managed nodes.
aws ssm describe-instance-information \
  --query 'InstanceInformationList[].{Id:InstanceId,Status:PingStatus,Platform:PlatformName,Agent:AgentVersion}' \
  --output table

# Open an interactive session (requires session-manager-plugin).
aws ssm start-session --target <instance_id>

# Run a one-off command across the ASG.
CMD_ID=$(aws ssm send-command \
  --document-name AWS-RunShellScript \
  --targets "Key=tag:aws:autoscaling:groupName,Values=<asg_name>" \
  --parameters 'commands=["docker ps","docker compose -f /opt/app/docker-compose.prod.yml ps","systemctl status docker --no-pager"]' \
  --query Command.CommandId --output text)

aws ssm list-command-invocations --command-id "$CMD_ID" --details \
  --query 'CommandInvocations[].{Inst:InstanceId,Status:Status,Out:CommandPlugins[0].Output}' \
  --output table
```

### 6.3 Instance Metadata (IMDSv2)

```bash
# From inside an instance via SSM session:
TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/iam/info
curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/dynamic/instance-identity/document | jq
```

### 6.4 Container-level debug on the instance

```bash
# Inside SSM session.
sudo -i
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
docker inspect <container> | jq '.[0].State, .[0].Config.Env'
docker logs --tail=500 <container>
docker logs --since 15m -f <container>
docker stats --no-stream

# Compose project on the host.
cd /opt/app
docker compose -f docker-compose.prod.yml ps
docker compose -f docker-compose.prod.yml logs --tail=200 backend
docker compose -f docker-compose.prod.yml exec backend curl -fsS http://localhost:8080/actuator/health
```

## 7. AWS - data (RDS MySQL 8.4)

### 7.1 RDS state

```bash
aws rds describe-db-instances \
  --db-instance-identifier java-app-prod-mysql \
  --query 'DBInstances[0].{Status:DBInstanceStatus,Engine:Engine,EngineVersion:EngineVersion,MultiAZ:MultiAZ,Storage:AllocatedStorage,Class:DBInstanceClass,EP:Endpoint.Address,Port:Endpoint.Port,Public:PubliclyAccessible,IAM:IAMDatabaseAuthenticationEnabled,Deletion:DeletionProtection,Backups:BackupRetentionPeriod,MajorUpg:AutoMinorVersionUpgrade,SecretArn:MasterUserSecret.SecretArn}'

aws rds describe-db-parameter-groups \
  --query 'DBParameterGroups[?contains(DBParameterGroupName, `java-app`)]'
aws rds describe-db-parameter-group-name <pg_name> 2>/dev/null
aws rds describe-events \
  --source-identifier java-app-prod-mysql --source-type db-instance \
  --duration 1440 \
  --query 'Events[].{Time:Date,Cat:EventCategories,Msg:Message}' --output table

# Pending maintenance.
aws rds describe-pending-maintenance-actions \
  --query 'PendingMaintenanceActions[].PendingMaintenanceActionDetails[].{Action:Action,AutoApply:AutoAppliedAfterDate,ForcedApply:ForcedApplyDate,Description:Description}'
```

### 7.2 Connect via SSM port-forward (RDS is in private subnets)

```bash
# Terminal A - start port forward through any healthy ASG instance.
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:aws:autoscaling:groupName,Values=<asg_name>" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)

DB_HOST=$(aws ssm get-parameter \
  --name /java-app/prod/db/endpoint --with-decryption \
  --query Parameter.Value --output text)

aws ssm start-session --target "$INSTANCE_ID" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$DB_HOST\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"3307\"]}"

# Terminal B - connect to the local end.
MASTER_SECRET_ARN=$(aws rds describe-db-instances \
  --db-instance-identifier java-app-prod-mysql \
  --query 'DBInstances[0].MasterUserSecret.SecretArn' --output text)
MASTER_PW=$(aws secretsmanager get-secret-value --secret-id "$MASTER_SECRET_ARN" \
  --query SecretString --output text | jq -r '.password')

mysql -h 127.0.0.1 -P 3307 -u admin -p"$MASTER_PW"
```

### 7.3 In-DB diagnostics

```sql
SELECT @@version, @@version_compile_machine, @@hostname;

-- Connections, threads, long-running queries.
SHOW GLOBAL STATUS LIKE 'Threads_%';
SELECT id, user, host, db, command, time, state, LEFT(info, 200) AS query
  FROM information_schema.processlist
  WHERE command <> 'Sleep' ORDER BY time DESC LIMIT 20;

-- InnoDB engine state (deadlocks, locks).
SHOW ENGINE INNODB STATUS\G

-- Slow queries.
SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 20;

-- Auth plugin per user (post-8.4 requirement, see RB-DB-001).
SELECT user, host, plugin FROM mysql.user WHERE user IN ('admin','appuser');

-- Flyway state in app DB.
SELECT installed_rank, version, description, success, installed_on
  FROM flyway_schema_history ORDER BY installed_rank;

-- Schema sanity.
SHOW TABLES;
SELECT table_schema, table_name, engine, table_rows, data_length, index_length
  FROM information_schema.tables WHERE table_schema = DATABASE();
```

## 8. AWS - secrets, config, image registry

### 8.1 Secrets Manager

```bash
aws secretsmanager list-secrets \
  --query 'SecretList[?starts_with(Name, `java-app/`) || starts_with(Name, `/java-app/`)].[Name,ARN,LastChangedDate]' \
  --output table

aws secretsmanager describe-secret --secret-id /java-app/prod/admin
aws secretsmanager get-secret-value --secret-id /java-app/prod/admin \
  --query SecretString --output text | jq 'keys'   # show keys only, do not echo values

# Rotation status.
aws secretsmanager describe-secret --secret-id /java-app/prod/admin \
  --query '{Rotation:RotationEnabled,LambdaArn:RotationLambdaARN,Rules:RotationRules}'
```

### 8.2 SSM Parameter Store (release pointers)

```bash
for k in \
  /java-app/prod/backend-image-tag \
  /java-app/prod/frontend-image-tag \
  /java-app/prod/release-id \
  /java-app/prod/db/endpoint
do
  aws ssm get-parameter --name "$k" --with-decryption \
    --query '{Name:Parameter.Name,Type:Parameter.Type,Version:Parameter.Version,Value:Parameter.Value,Modified:Parameter.LastModifiedDate}'
done

# History on a single parameter.
aws ssm get-parameter-history --name /java-app/prod/release-id \
  --query 'Parameters[].{Ver:Version,User:LastModifiedUser,Time:LastModifiedDate,Value:Value}' \
  --output table
```

### 8.3 ECR

```bash
aws ecr describe-repositories \
  --query 'repositories[?contains(repositoryName, `java-app`)].[repositoryName,repositoryUri,imageScanningConfiguration.scanOnPush]' \
  --output table

REPO=java-app-backend
aws ecr describe-images --repository-name "$REPO" \
  --query 'imageDetails | sort_by(@, &imagePushedAt) | reverse(@) | [:10].{Tags:imageTags,Pushed:imagePushedAt,Digest:imageDigest,SizeMB:imageSizeInBytes}' \
  --output table

aws ecr describe-image-scan-findings --repository-name "$REPO" \
  --image-id imageTag=<sha> \
  --query '{Status:imageScanStatus.status,Counts:imageScanFindings.findingSeverityCounts}'

# Login for local pull/push.
aws ecr get-login-password | \
  docker login --username AWS --password-stdin <acct>.dkr.ecr.<region>.amazonaws.com
```

## 9. CloudWatch (logs, metrics, alarms)

```bash
# Log groups in scope.
aws logs describe-log-groups \
  --query 'logGroups[?contains(logGroupName, `java-app`)].{Name:logGroupName,Retention:retentionInDays,Bytes:storedBytes}' \
  --output table

# Tail (CLI v2).
aws logs tail /java-app/prod/backend --follow --since 30m
aws logs tail /java-app/prod/backend --since 1h \
  --filter-pattern '?ERROR ?Exception ?WARN' --format short

# Insights query (last 1h, error timeline).
QUERY='fields @timestamp, level, logger, message
| filter level in ["ERROR","WARN"]
| sort @timestamp desc
| limit 200'

QID=$(aws logs start-query \
  --log-group-name /java-app/prod/backend \
  --start-time $(($(date +%s)-3600)) \
  --end-time $(date +%s) \
  --query-string "$QUERY" \
  --query queryId --output text)
sleep 5
aws logs get-query-results --query-id "$QID"

# Metric quick-look (target group 5xx).
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HTTPCode_Target_5XX_Count \
  --dimensions Name=TargetGroup,Value=<tg_short_arn> Name=LoadBalancer,Value=<lb_short_arn> \
  --statistics Sum --period 60 \
  --start-time $(date -u -v-1H +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --query 'Datapoints | sort_by(@, &Timestamp)'

# Active alarms.
aws cloudwatch describe-alarms --state-value ALARM \
  --query 'MetricAlarms[].{Name:AlarmName,Reason:StateReason,Updated:StateUpdatedTimestamp}'
```

## 10. SES (outbound email)

```bash
aws sesv2 get-account
aws sesv2 list-email-identities --query 'EmailIdentities[].{Id:IdentityName,Type:IdentityType,Verified:VerifiedForSendingStatus}'
aws sesv2 get-email-identity --email-identity talorlik.com \
  --query '{DKIM:DkimAttributes,Mail:MailFromAttributes,Verified:VerifiedForSendingStatus}'

# Send statistics (24h).
aws ses get-send-statistics --query 'SendDataPoints | sort_by(@,&Timestamp) | [-24:]'

# Suppression list (bounces/complaints).
aws sesv2 list-suppressed-destinations --query 'SuppressedDestinationSummaries[]'
```

## 11. GitHub Actions / OIDC

```bash
# Authenticate gh CLI.
gh auth status

# Inspect workflow files locally.
ls -1 .github/workflows
yamllint .github/workflows || true   # if installed

# List recent runs per workflow.
gh run list --workflow ci.yml --limit 10
gh run list --workflow infra-plan.yml --limit 10
gh run list --workflow app-deploy.yml --limit 10

# Drill into a failing run.
gh run view <run_id> --log-failed
gh run view <run_id> --json jobs --jq '.jobs[] | {name,conclusion,steps:[.steps[] | {name,conclusion}]}'

# Manual dispatch (mutating: triggers a real run).
gh workflow run app-deploy.yml -f image_tag=sha-<12hex>            # mutating
gh workflow run infra-plan.yml                                     # mutating

# Repo-level vars and secrets (names only; values redacted server-side).
gh variable list
gh secret list
```

## 12. Post-RDS-upgrade checks (ADR 0008, RB-DB-001)

```bash
# 1. Confirm engine version.
aws rds describe-db-instances --db-instance-identifier java-app-prod-mysql \
  --query 'DBInstances[0].{Version:EngineVersion,Status:DBInstanceStatus,Pending:PendingModifiedValues}'

# 2. Confirm appuser auth plugin (must be caching_sha2_password on 8.4+).
#    Run via SSM port-forward + master password (see section 7.2):
#    SELECT user, host, plugin FROM mysql.user WHERE user='appuser';

# 3. After successful upgrade, propose a follow-up PR to flip:
#      infra/envs/prod/rds.tf:68  allow_major_version_upgrade = false
#      infra/envs/prod/rds.tf:73  remove apply_immediately = true
#    (do not run apply from agent context).
```

## 13. Playwright E2E

```bash
cd tests/e2e
npm ci
npx playwright install --with-deps          # mutating disk write

# Full suite.
npx playwright test --reporter=list,html

# Targeted.
npx playwright test specs/auth.spec.ts -g "login"
npx playwright test --debug                  # opens Inspector
PWDEBUG=1 npx playwright test specs/auth.spec.ts

# Trace + report viewer.
npx playwright show-report
npx playwright show-trace test-results/<dir>/trace.zip

# Codegen against staging URL.
npx playwright codegen https://java.talorlik.com
```

## 14. Failure-mode quick-reference

| Symptom | First three commands |
|---|---|
| ALB returns 5xx, app reachable internally | `aws elbv2 describe-target-health ...`, `aws ssm send-command ... 'docker ps'`, `aws logs tail /java-app/prod/backend --since 15m` |
| Instance refresh stuck | `aws autoscaling describe-instance-refreshes`, `aws autoscaling describe-scaling-activities`, `aws ec2 describe-launch-template-versions ... UserData` |
| RDS connect failures after upgrade | `aws rds describe-db-instances`, port-forward + `SELECT user,host,plugin FROM mysql.user`, `SHOW ENGINE INNODB STATUS\G` |
| New ECR image won't roll out | `aws ssm get-parameter --name /java-app/prod/backend-image-tag`, `aws ecr describe-images --repository-name java-app-backend`, `gh run view <id> --log-failed` |
| Cert/TLS error at edge | `openssl s_client -connect $DOMAIN:443 -servername $DOMAIN`, `aws acm describe-certificate --certificate-arn ...`, `aws route53 list-resource-record-sets --hosted-zone-id ...` |
| Terraform "state locked" | `aws s3api head-object ... .tflock`, identify the run owner, then `terraform force-unlock <id>` (mutating) |
| Flyway migration failure on boot | `aws logs tail /java-app/prod/backend --filter-pattern 'Flyway'`, in-DB `SELECT * FROM flyway_schema_history WHERE success=0`, `./mvnw flyway:info` |
| WAF blocking legitimate traffic | `aws wafv2 get-sampled-requests ...`, `aws wafv2 get-web-acl ...`, `aws logs tail aws-waf-logs-... --since 30m` |

## 15. Operator notes

- All long-running interactive commands (SSM session, port-forward,
  `playwright --debug`) should run in their own terminal so they can be
  torn down with Ctrl+C without losing other context.
- When a debug command needs cross-account access (Route53), assume the
  DOMAIN role explicitly with `aws sts assume-role` and export the
  resulting `AKIA*`/`SecretAccessKey`/`SessionToken` for the lifetime of
  the call. Do not edit shared `~/.aws/credentials`.
- `aws logs tail --follow` is idempotent and read-only; safe to leave
  attached during incidents.
- Any command flagged `# mutating` in this file changes state - confirm
  blast radius before invoking and pair with a git/SSM record if it runs
  outside CI.

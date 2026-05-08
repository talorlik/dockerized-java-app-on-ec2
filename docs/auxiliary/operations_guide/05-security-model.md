# 05 - Security model

## Network

- ALB is the only public surface. Listeners: HTTPS `443` (TLS termination)
  and HTTP `80` (301 redirect to HTTPS, no traffic forwarded to the app tier).
- EC2 has no public IPs and no SSH ingress. Access via SSM Session Manager.
- RDS is in private DB subnets and has no public endpoint.
- Inter-tier rules use SG references, not CIDRs.
- WAFv2 web ACL attached to ALB with managed Common + KnownBadInputs + SQLi
  rule sets, plus a per-IP rate limit (2000 req / 5m).

## Identity

- GitHub OIDC -> DEPLOYMENT `github-role` for CI/CD.
- DEPLOYMENT `github-role` may assume DOMAIN `route53-dns-manager-role` via
  the aliased Terraform provider for cross-account DNS writes.
- EC2 instance profile (`java-app-prod-app-instance`) has only:
  `AmazonSSMManagedInstanceCore`, `CloudWatchAgentServerPolicy`,
  `AmazonEC2ContainerRegistryReadOnly`, plus an inline policy scoped to:
  - `secretsmanager:GetSecretValue` on the four app secret ARNs and the RDS
    master secret.
  - `ssm:GetParameter*` on `/java-app/prod/*`.
  - `kms:Decrypt` on the secrets CMK only.
  - `ses:SendEmail` on the approved identity ARN only.
  - `logs:Put*` for CloudWatch.
  - `ecr:GetAuthorizationToken` (must be `*`).

## Secrets

- All under `/java-app/prod/*`:
  - `db/app-user` - least-privileged DB user (Terraform-generated).
  - `db/master`   - RDS-managed master credential (rotated by AWS).
  - `admin`       - bootstrap admin (Terraform-generated, seeded by app at startup).
  - `jwt`         - HMAC signing key for backend JWT.
  - `ses`         - SES sender identity / region.
- All encrypted with the `alias/java-app-prod-secrets` CMK.
- Nothing is committed to source control. `terraform.tfvars` is `.gitignore`'d.
- App logs never include secret values; SES errors log only the exception
  class name and recipient.

### Manual rotation - `db/app-user`

Automatic rotation is intentionally out of scope (see ADR 0005, ADR 0007).
To rotate the `appuser` password:

1. Generate a new password:
   ```bash
   NEW=$(aws secretsmanager get-random-password \
     --password-length 32 \
     --exclude-characters '"@/\\' \
     --query RandomPassword --output text)
   ```
2. Write the new value to Secrets Manager:
   ```bash
   aws secretsmanager put-secret-value \
     --secret-id /java-app/prod/db/app-user \
     --secret-string "$(jq -n --arg u appuser --arg p "$NEW" \
        '{username:$u, password:$p}')"
   ```
3. Apply it on the live MySQL instance, authenticated as `dbadmin` with
   the master secret:
   ```sql
   ALTER USER 'appuser'@'%' IDENTIFIED WITH caching_sha2_password BY '<NEW>';
   FLUSH PRIVILEGES;
   ```
4. Trigger an ASG instance refresh so EC2s re-read the secret on boot.
   Long-lived instances retain the previous credential in `/opt/java-app/.env`
   until they recycle.

## Compute hardening

- IMDSv2 required (`http_tokens=required`).
- Encrypted gp3 root EBS volume.
- IAM-only DB master, app uses dedicated user.
- Docker logs: json-file driver with rotation (`max-size=10m`, `max-file=5`).

## TLS

- ELBSecurityPolicy-TLS13-1-2-2021-06.
- ACM certificate from DEPLOYMENT account.
- HSTS, CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy
  emitted by Nginx.

## Application

- Passwords: BCrypt (cost 12).
- Verification codes: hashed at rest with BCrypt; 30-min TTL; max 5 attempts.
- Login + verify + signup rate limited per email key.
- Generic auth failure messages (no user enumeration).
- Email field is non-modifiable on profile.
- Admin endpoints gated by `ROLE_ADMIN`.
- CORS limited to the public origin.

## State storage

- S3 bucket: SSE-KMS, versioning on, public access blocked, TLS-only policy,
  90-day noncurrent-version lifecycle.

## Incident verification

- ALB access logs and VPC flow logs are searchable with Athena.
- All admin user mutations are recorded in `audit_events` with actor email.

# 02 - Cross-account DNS and SES

Two account boundaries to wire up before `terraform apply` in `infra/envs/prod`
will succeed.

## Hosted zone

- DOMAIN account holds the public hosted zone for `talorlik.com`.
- Capture the zone ID and set it as the GitHub repo variable `HOSTED_ZONE_ID`.

## Route53 cross-account role

In DOMAIN account create `route53-dns-manager-role` with:

- Trust policy: allow `sts:AssumeRole` from DEPLOYMENT account
  `github-role` (or DEPLOYMENT account root if you prefer narrower scoping
  via session tags).
- Permissions: minimal Route53 write to `talorlik.com` and SES record paths.

Example trust policy (DOMAIN account):

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "AWS": "arn:aws:iam::DEPLOYMENT_ACCOUNT_ID:role/github-role" },
    "Action": "sts:AssumeRole"
  }]
}
```

Example permission policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:GetChange",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/HOSTED_ZONE_ID"
    },
    {
      "Effect": "Allow",
      "Action": [ "route53:ListHostedZones", "route53:GetHostedZone" ],
      "Resource": "*"
    }
  ]
}
```

Set the role ARN as the GitHub repo secret `DOMAIN_ROUTE53_ROLE_ARN`.

## ACM

Issue a certificate in DEPLOYMENT account (`us-east-1`) for
`java.talorlik.com`. Validate using DNS records in the DOMAIN account zone.
Once issued, set the ARN as `ACM_CERTIFICATE_ARN` repo secret.

## SES

Terraform creates an SES domain identity for the configured sender subdomain
and writes the DKIM CNAMEs into the DOMAIN account zone via the aliased
provider. Production sending access (escape from sandbox) must be requested
manually in the SES console after first apply if your account is still in
sandbox.

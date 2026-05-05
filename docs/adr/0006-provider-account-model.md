# ADR 0006 - Two-account Terraform provider model

## Status
Accepted

## Context
Hosted zone for `talorlik.com` lives in DOMAIN account; everything else lives
in DEPLOYMENT account. We want a single Terraform run to manage both.

## Decision
Use one default `aws` provider for DEPLOYMENT and one aliased `aws.domain`
provider that assumes a Route53-write role in DOMAIN. Cross-account is
limited to Route53 record changes (app A alias + SES DKIM CNAMEs).

## Consequences
- Single `terraform apply` brings up infrastructure end-to-end.
- DOMAIN account exposure is limited to the explicit Route53 role.
- If the DOMAIN role is unavailable, Terraform fails fast on the cross-
  account resources rather than silently skipping them.

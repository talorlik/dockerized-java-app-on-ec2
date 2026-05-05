# ADR 0004 - Ubuntu LTS resolution strategy

## Status
Accepted

## Context
Latest Ubuntu LTS varies by region availability. Hard-coding an AMI ID
ages immediately.

## Decision
Resolve the AMI at `terraform apply` time via Canonical's public SSM
Parameter Store namespace:
`/aws/service/canonical/ubuntu/server/<codename>/stable/current/amd64/hvm/ebs-gp3/ami-id`.
The codename is a Terraform variable (`var.ubuntu_lts_codename`, default
`noble` = 24.04).

## Consequences
- New instances always get the latest stable image of the chosen LTS line.
- Image drift is bounded by Terraform - operators must run apply (or trigger
  a no-op refresh) to pick up the latest image.
- Switching to `26.04` once GA in `us-east-1` is a one-line variable change
  followed by an instance refresh (unverified - check Canonical's listing
  before flipping).

###############################################################################
# Route53 - cross-account A alias to ALB.
# Domain hosted zone lives in the DOMAIN account; record is created using
# the aliased provider that assumes the DOMAIN-account Route53 role.
###############################################################################

resource "aws_route53_record" "app_alias" {
  provider = aws.domain
  zone_id  = var.hosted_zone_id
  name     = var.app_subdomain
  type     = "A"

  # If a previous infra-destroy partially failed and left the record in the
  # DOMAIN account hosted zone, allow_overwrite lets the next apply replace
  # it instead of erroring with "RR exists with different value".
  allow_overwrite = true

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

###############################################################################
# SES sender identity (subdomain) + DKIM CNAMEs in the DOMAIN account.
###############################################################################

resource "aws_sesv2_email_identity" "sender" {
  email_identity         = var.ses_sender_subdomain
  configuration_set_name = aws_sesv2_configuration_set.app.configuration_set_name
}

# DKIM CNAMEs are returned as a list of 3 tokens; publish them in the DOMAIN
# account hosted zone via the aliased provider.
resource "aws_route53_record" "ses_dkim" {
  provider = aws.domain
  count    = 3

  zone_id = var.hosted_zone_id
  name    = "${aws_sesv2_email_identity.sender.dkim_signing_attributes[0].tokens[count.index]}._domainkey.${var.ses_sender_subdomain}"
  type    = "CNAME"
  ttl     = 600
  records = ["${aws_sesv2_email_identity.sender.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]
  # Same reasoning as aws_route53_record.app_alias - tolerate stale records
  # left over by a partial infra-destroy.
  allow_overwrite = true
}

resource "aws_sesv2_configuration_set" "app" {
  configuration_set_name = "${local.name_prefix}-ses"

  delivery_options {
    tls_policy = "REQUIRE"
  }

  reputation_options {
    reputation_metrics_enabled = true
  }

  sending_options {
    sending_enabled = true
  }
}

resource "aws_sesv2_configuration_set_event_destination" "cw" {
  configuration_set_name = aws_sesv2_configuration_set.app.configuration_set_name
  event_destination_name = "cloudwatch"

  event_destination {
    enabled = true
    matching_event_types = [
      "SEND", "REJECT", "BOUNCE", "COMPLAINT", "DELIVERY", "RENDERING_FAILURE", "DELIVERY_DELAY"
    ]
    cloud_watch_destination {
      dimension_configuration {
        default_dimension_value = "default"
        dimension_name          = "MessageTag"
        dimension_value_source  = "MESSAGE_TAG"
      }
    }
  }
}

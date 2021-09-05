module "ses" {
  source = "trussworks/ses-domain/aws"
  route53_zone_id = data.aws_route53_zone.main.zone_id

  domain_name = var.domain
  enable_verification = true

  enable_incoming_email = false

  dmarc_p = "reject"
  dmarc_rua = var.dmarc_address

  enable_spf_record = true

  mail_from_domain = "mail.${var.domain}"
  from_addresses = var.from_addresses
  ses_rule_set = var.domain
}


resource "aws_ses_domain_identity" "app" {
  domain = var.app_domain
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.app.zone_id
  name    = "_amazonses.${var.app_domain}"
  type    = "TXT"
  ttl     = "600"
  records = [join("", aws_ses_domain_identity.app.*.verification_token)]
}

resource "aws_ses_domain_dkim" "app_dkim" {
  domain = join("", aws_ses_domain_identity.app.*.domain)
}

resource "aws_route53_record" "app_record" {
  count = 3

  zone_id = data.aws_route53_zone.app.zone_id
  name    = "${element(aws_ses_domain_dkim.app_dkim.dkim_tokens, count.index)}._domainkey.${var.app_domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.app_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

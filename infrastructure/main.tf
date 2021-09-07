module "ses" {
  source = "trussworks/ses-domain/aws"
  route53_zone_id = data.aws_route53_zone.main.zone_id
  domain_name = var.domain

  enable_verification = true

  enable_incoming_email = true

  dmarc_p = "reject"
  dmarc_rua = var.dmarc_address

  enable_spf_record = true

  mail_from_domain = var.from_domain
  from_addresses = var.from_addresses
  ses_rule_set = aws_ses_receipt_rule_set.ses.rule_set_name

  receive_s3_bucket = aws_s3_bucket.ses.id
  receive_s3_prefix = var.ses_bucket_prefix
}
resource "aws_ses_receipt_rule_set" "ses" {
  rule_set_name = var.domain
}
resource "aws_ses_active_receipt_rule_set" "ses" {
  rule_set_name = aws_ses_receipt_rule_set.ses.rule_set_name
}

resource "aws_ses_email_identity" "email_address" {
  count = length(var.from_addresses)
  email = var.from_addresses[count.index]
}

data "aws_iam_policy_document" "ses_s3_puts" {
  statement {
    sid = "allow-ses-puts"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "ses.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.ses_bucket}/${var.ses_bucket_prefix}/*",
    ]

    condition {
      test = "StringEquals"
      variable = "aws:Referer"
      values = [
        data.aws_caller_identity.current.id]
    }
  }
}

resource "aws_s3_bucket" "ses" {
  bucket = var.ses_bucket
  acl = "private"
  force_destroy = true
  policy = data.aws_iam_policy_document.ses_s3_puts.json

  logging {
    target_bucket = module.s3_logs.aws_logs_bucket
    target_prefix = "s3/${var.ses_bucket}/"
  }
}
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.ses.id
  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}

module "s3_logs" {
  source = "trussworks/logs/aws"
  version = "~> 8"

  s3_bucket_name = "${var.ses_bucket}-logs"

  default_allow = false
}

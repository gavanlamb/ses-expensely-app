data "aws_route53_zone" "main" {
  name = var.domain
}

data "aws_caller_identity" "current" {}
data "aws_route53_zone" "app" {
  name = var.app_domain
}

data "aws_caller_identity" "current" {}

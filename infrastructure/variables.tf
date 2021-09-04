variable "environment" {
  type = string
}
variable "region" {
  type = string
}

variable "app_domain" {
  type = string
}

locals {
  default_tags = {
    Application = "Expensely"
    Team = "Expensely Core"
    ManagedBy = "Terraform"
    Environment = var.environment
  }
}

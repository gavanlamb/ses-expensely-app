variable "environment" {
  type = string
}
variable "region" {
  type = string
}

variable "domain" {
  type = string
}
variable "dmarc_address" {
  type = string
}
variable "from_addresses" {
  type = list(string)
}

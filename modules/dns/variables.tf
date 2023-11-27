variable "site_domain" {
  type = string
  description = "domain that the record is going to be appended to"
  default = "omar.earth"
}

variable "record_name" {
  type = string
  description = "the name column is e.g. www; creates a subdomain if an a record"
}

variable "record_value" {
  type = string
  description = "if an A record then this is usually an ip address"
}

variable "record_type" {
  type = string
  description = "can be A, AAAAAA, CNAME, etc."
  default = "A"
}

variable "proxied" {
  type = bool
  description = "decide whether to use Cloudflare's proxying"
  default = true
}

variable "cloudflare_api_token" {}

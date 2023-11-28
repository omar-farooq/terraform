variable "site_domain" {
  type = string
  description = "The domain used to access the website over the internet"
}

variable "apex" {
  type = string
  description = "The base/apex record used to find the zone"
}

variable "cloudflare_api_token" {
  type = string
}

variable "site_domain" {
  type = string
  description = "The domain used to access the website over the internet"
}

variable "cloudfront_distribution" {
  type = string
  description = "The arn of the distribution created for use in the bucket policy to allow it"
}

variable "cloudflare_api_token" {
  type = string
}

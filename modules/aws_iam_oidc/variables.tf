variable "provider_tls_url" {
  type    = string
  # Avoid using https scheme because the Hashicorp TLS provider has started following redirects starting v4.
  # See https://github.com/hashicorp/terraform-provider-tls/issues/249
}

variable "provider_url" {
  type    = string
}

variable "aud_value" {
  type    = string
}

variable "conditions" {
  type  = list(object({
    test        = string
    variable    = string
    values      = list(string)
  }))
}

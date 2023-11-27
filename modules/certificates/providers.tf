terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~>4.0"
    }
  }
}


provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

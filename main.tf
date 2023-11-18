terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "omar-terraform"
    key    = "state/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region  = "eu-west-2"
  profile = "default"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "omar-website-frontend" {
  source               = "./modules/static-site"
  site_domain          = "omar.earth"
  cloudflare_api_token = var.cloudflare_api_token
}

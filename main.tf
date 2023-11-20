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

module "omar-website-frontend" {
  source               = "./modules/static-site"
  site_domain          = "omar.earth"
  cloudflare_api_token = var.cloudflare_api_token
}

module "omar-website-form-function" {
  source        = "./modules/functions"
  function_name = "omar-earth-form"
  image_uri     = "${module.gomar-repository.uri}:latest"
  envs = {
    EMAIL_TO   = "omrrrrrrr@gmail.com"
    EMAIL_FROM = "form@omar.earth"
  }
  function_url = true
}

module "gomar-repository" {
  source = "./modules/repositories"
  name   = "gomar"
}

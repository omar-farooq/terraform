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
  region = "us-east-1"
  alias = "us-east-1"
}

module "omar-site-certificate" {
  source               = "./modules/certificates"
  site_domain          = "omar.earth"
  cloudflare_api_token = var.cloudflare_api_token
  providers = {
    aws = aws.us-east-1
  }
}

module "omar-website-frontend" {
  source               = "./modules/static-site"
  site_domain          = "omar.earth"
  cloudflare_api_token = var.cloudflare_api_token
}

module "redirect-http-ext" {
  source = "./modules/cloudfront-functions"
  name = "redirect-http-ext"
  file = "redirect-http.js"
}

module "omar-website-cloudfront-distribution" {
  source = "./modules/cloudfront"
  origin_domain = module.omar-website-frontend.bucket_website_endpoint
  origin_id = module.omar-website-frontend.bucket_id
  cert = module.omar-site-certificate.certificate_arn
  aliases = ["omar.earth"]
  comment = "Omar personal website"
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

module "omar-earth-dns-record" {
  source = "./modules/dns"
  cloudflare_api_token = var.cloudflare_api_token
  site_domain = "omar.earth"
  record_name = "omar.earth"
  record_value = module.omar-website-cloudfront-distribution.domain
  record_type = "CNAME"
  proxied = false
}

module "gomar-repository" {
  source = "./modules/repositories"
  name   = "gomar"
}

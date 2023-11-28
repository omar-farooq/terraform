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
  alias  = "us-east-1"
}

module "omar-site-certificate" {
  source               = "./modules/certificates"
  site_domain          = "omar.earth"
  apex = "omar.earth"
  cloudflare_api_token = var.cloudflare_api_token
  providers = {
    aws = aws.us-east-1
  }
}

module "omar-api-certificate" {
  source               = "./modules/certificates"
  site_domain          = "api.omar.earth"
  apex = "omar.earth"
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

module "add-html-ext" {
  source = "./modules/cloudfront-functions"
  name   = "add-html-ext"
  file   = "add-html-ext.js"
}

module "omar-website-cloudfront-distribution" {
  source           = "./modules/cloudfront"
  origin_domain    = module.omar-website-frontend.bucket_website_endpoint
  origin_id        = module.omar-website-frontend.bucket_id
  cert             = module.omar-site-certificate.certificate_arn
  aliases          = ["omar.earth"]
  comment          = "Omar personal website"
  add_html_ext_arn = module.add-html-ext.arn
  contact_lambda = module.omar-website-form-function.lambda_arn
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
  source               = "./modules/dns"
  cloudflare_api_token = var.cloudflare_api_token
  site_domain          = "omar.earth"
  record_name          = "omar.earth"
  record_value         = module.omar-website-cloudfront-distribution.domain
  record_type          = "CNAME"
  proxied              = false
}

module "gomar-repository" {
  source = "./modules/repositories"
  name   = "gomar"
}

module "api-omar-earth" {
  source = "./modules/api-domains"
  cert = module.omar-api-certificate.certificate_arn
  domain = "api.omar.earth"
}

module "omar-api-dns-record" {
  source               = "./modules/dns"
  cloudflare_api_token = var.cloudflare_api_token
  site_domain          = "omar.earth"
  record_name          = "api.omar.earth"
  record_value         = module.api-omar-earth.cloudfront_domain
  record_type          = "CNAME"
  proxied              = false
}

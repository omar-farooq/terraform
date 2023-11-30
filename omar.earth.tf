module "omar-site-certificate" {
  source               = "./modules/certificates"
  site_domain          = "omar.earth"
  apex                 = "omar.earth"
  cloudflare_api_token = var.cloudflare_api_token
  providers = {
    aws = aws.us-east-1
  }
}

module "omar-api-certificate" {
  source               = "./modules/certificates"
  site_domain          = "api.omar.earth"
  apex                 = "omar.earth"
  cloudflare_api_token = var.cloudflare_api_token
}

module "omar-website-frontend" {
  source               = "./modules/static-site"
  site_domain          = "omar.earth"
  cloudfront_distribution = module.omar-website-cloudfront-distribution.distribution_arn
  cloudflare_api_token = var.cloudflare_api_token
}

module "add-html-ext" {
  source = "./modules/cloudfront-functions"
  name   = "add-html-ext"
  file   = "add-html-ext.js"
}

module "omar-website-cloudfront-distribution" {
  source           = "./modules/cloudfront"
  origin_domain    = module.omar-website-frontend.bucket_domain
  origin_id        = module.omar-website-frontend.bucket_id
  cert             = module.omar-site-certificate.certificate_arn
  aliases          = ["omar.earth"]
  comment          = "Omar personal website"
  add_html_ext_arn = module.add-html-ext.arn
  contact_lambda   = module.omar-website-form-function.lambda_arn
}

module "omar-website-form-function" {
  source        = "./modules/functions"
  function_name = "omar-earth-form"
  image_uri     = "${module.gomar-repository.uri}:latest"
  envs = {
    EMAIL_TO   = "omrrrrrrr@gmail.com"
    EMAIL_FROM = "form@omar.earth"
  }
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
  cert   = module.omar-api-certificate.certificate_arn
  domain = "api.omar.earth"
}

module "omar-api-dns-record" {
  source               = "./modules/dns"
  cloudflare_api_token = var.cloudflare_api_token
  site_domain          = "omar.earth"
  record_name          = "api.omar.earth"
  record_value         = module.api-omar-earth.target_domain
  record_type          = "CNAME"
  proxied              = false
}

module "omar-contact-form-gateway" {
  source = "./modules/lambda-rest-api-gw"
  name = "contact"
  path_part = "contact"
  lambda_invoke_arn = module.omar-website-form-function.invoke_arn
  lambda_fn_name = module.omar-website-form-function.function_name
  domain_name = "api.omar.earth"
}

module "contact-form-usage" {
  source = "./modules/gw-usage-plans"
  name = "contact-form-limits"
  api_id = module.omar-contact-form-gateway.gw_id
  stage_name = module.omar-contact-form-gateway.stage_name
  key_name = "contact-key"
}

resource "aws_ses_email_identity" "omar" {
  email = "omrrrrrrr@gmail.com"
}

resource "aws_ses_domain_identity" "omar_earth" {
  domain = "omar.earth"
}

resource "aws_ses_domain_mail_from" "omar_earth" {
  domain           = aws_ses_domain_identity.omar_earth.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.omar_earth.domain}"
}

resource "aws_ses_domain_dkim" "omar_earth" {
  domain = aws_ses_domain_identity.omar_earth.domain
}

resource "cloudflare_record" "omar_earth_ses_domain_mail_from_mx" {
  zone_id  = "3e56238d05818e4f738b7270c76c4c75"
  name     = aws_ses_domain_mail_from.omar_earth.mail_from_domain
  type     = "MX"
  ttl      = "600"
  priority = "10"
  value    = "feedback-smtp.eu-west-2.amazonses.com"
}

resource "cloudflare_record" "omar_earth_ses_domain_mail_from_txt" {
  zone_id = "3e56238d05818e4f738b7270c76c4c75"
  name    = aws_ses_domain_mail_from.omar_earth.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  value   = "v=spf1 include:amazonses.com -all"
}

resource "cloudflare_record" "omar_earth_ses_verification_record" {
  zone_id = "3e56238d05818e4f738b7270c76c4c75"
  name    = "_amazonses.omar.earth"
  type    = "TXT"
  ttl     = "600"
  value   = aws_ses_domain_identity.omar_earth.verification_token
}

resource "cloudflare_record" "omar_earth_amazonses_dkim_record" {
  count   = 3
  zone_id = "3e56238d05818e4f738b7270c76c4c75"
  name    = "${aws_ses_domain_dkim.omar_earth.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  value   = "${aws_ses_domain_dkim.omar_earth.dkim_tokens[count.index]}.dkim.amazonses.com"
}

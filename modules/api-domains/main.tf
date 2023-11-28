resource "aws_api_gateway_domain_name" "domain" {
  certificate_arn = var.cert
  domain_name = var.domain
}

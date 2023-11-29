resource "aws_apigatewayv2_domain_name" "domain" {
  domain_name_configuration {
    certificate_arn = var.cert
    endpoint_type = "REGIONAL"
    security_policy = "TLS_1_2"
  }
  domain_name = var.domain
}

output "target_domain" {
  value = aws_apigatewayv2_domain_name.domain.domain_name_configuration[0].target_domain_name
  description = "The resulting domain created on AWS that represents the record value in the DNS CNAME"
}

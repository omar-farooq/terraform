output "cloudfront_domain" {
  value = aws_api_gateway_domain_name.domain.cloudfront_domain_name
  description = "The cloudfront domain created as a result of the domain being created"
}

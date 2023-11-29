output "domain" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "The domain that the cloudfront distribution is available at"
}

output "distribution_arn" {
  value = aws_cloudfront_distribution.s3_distribution.arn
}

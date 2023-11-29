output "bucket_website_endpoint" {
  description = "The website endpoint of the bucket rather than the bucket domain"
  value = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "bucket_id" {
  description = "The id of the newly created bucket"
  value = aws_s3_bucket.site.id
}

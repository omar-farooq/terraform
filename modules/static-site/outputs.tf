output "bucket_domain" {
  value = aws_s3_bucket.site.bucket_regional_domain_name
}

output "bucket_id" {
  description = "The id of the newly created bucket"
  value = aws_s3_bucket.site.id
}

output "bucket_arn" {
  description = "Arn of the bucket"
  value = aws_s3_bucket.site.arn
}

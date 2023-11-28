output "arn" {
  value = aws_cloudfront_function.fn.arn
  description = "The arn of the function created"
}

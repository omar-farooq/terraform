resource "aws_cloudfront_function" "fn" {
  name = var.name
  runtime = "cloudfront-js-1.0"
  publish = true
  code = file("${path.module}/${var.file}")
}

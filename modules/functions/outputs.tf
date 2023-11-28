output "lambda_arn" {
  value = aws_lambda_function.lambda.qualified_arn
  description = "The resulting arn of the aws lambda function url"
}

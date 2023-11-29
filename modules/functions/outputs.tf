output "lambda_arn" {
  value = aws_lambda_function.lambda.qualified_arn
  description = "The resulting arn of the aws lambda function url"
}

output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
  description = "invoke arn used by the api gateway integration"
}

output "function_name" {
  value = aws_lambda_function.lambda.function_name
  description = "function name used by for api gateway permissions"
}

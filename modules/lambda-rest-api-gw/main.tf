resource "aws_api_gateway_rest_api" "api" {
  name = var.name
}

resource "aws_api_gateway_resource" "resource" {
  parent_id = aws_api_gateway_rest_api.api.root_resource_id
  path_part = var.path_part
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "method" {
  authorization = "NONE"
  http_method = "POST"
  resource_id = aws_api_gateway_resource.resource.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  api_key_required = true
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "lambda" {
  http_method = aws_api_gateway_method.method.http_method
  resource_id = aws_api_gateway_resource.resource.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  integration_http_method = "POST"
  type = "AWS"
  uri = var.lambda_invoke_arn
}

resource "aws_api_gateway_integration_response" "IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.api.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.lambda.id,
      aws_api_gateway_method.method.api_key_required,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "production"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_fn_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_api_gateway_base_path_mapping" "map" {
  api_id = aws_api_gateway_rest_api.api.id
  stage_name = aws_api_gateway_stage.production.stage_name
  domain_name = var.domain_name
}

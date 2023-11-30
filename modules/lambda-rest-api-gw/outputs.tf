output "gw_id" {
  value = aws_api_gateway_rest_api.api.id
  description = "resulting id of the created api gateway"
}

output "stage_name" {
  value = aws_api_gateway_stage.production.stage_name
}

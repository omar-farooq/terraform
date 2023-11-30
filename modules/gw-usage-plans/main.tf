resource "aws_api_gateway_usage_plan" "plan" {
  name = var.name

  api_stages {
    api_id = var.api_id
    stage = var.stage_name
  }

  quota_settings {
    limit = var.limit
    period = var.period
  }

  throttle_settings {
    burst_limit = var.burst_limit
    rate_limit = var.rate_limit
  }
}

resource "aws_api_gateway_api_key" "key" {
  name = var.key_name
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.plan.id
}

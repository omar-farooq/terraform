variable "name" {
  type = string
  description = "desired name of the api gateway"
}

variable "description" {
  type = string
}

variable "route_key" {
  type = string
  description = "The method followed by the route e.g. POST /contact (or ALL)"
}

variable "lambda_invoke_arn" {
  type = string
  description = "The invocation arn of the contact form lambda"
}

variable "lambda_fn_name" {
  type = string
  description = "Name of the lambda function given"
}

variable "name" {
  type = string
  description = "desired name of the api gateway"
}

variable "path_part" {
  type = string
  description = "The last path segment - e.g. contact"
}

variable "lambda_invoke_arn" {
  type = string
  description = "The invocation arn of the contact form lambda"
}

variable "lambda_fn_name" {
  type = string
  description = "Name of the lambda function given"
}

variable "domain_name" {
  type = string
  description = "The easy-to-remember domain that the api is a part of"
}

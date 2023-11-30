variable "name" {
  type = string
}

variable "api_id" {
  type = string
  description = "ID of the associated API"
}

variable "stage_name" {
  type = string
  description = "The stage of the associated API"
}

variable "limit" {
  type = number
  description = "How many requests can be made in a given period of time (defined below)"
  default = 30
}

variable "period" {
  type = string
  description = "Period of time the limit applies to"
  default = "DAY"
}

variable "burst_limit" {
  type = number
  description = "Applies to throttle settings"
  default = 2
}

variable "rate_limit" {
  type = number
  description = "Applies to throttle settings"
  default = 1
}

variable "key_name" {
  type = string
  description = "Name given to the api key"
}

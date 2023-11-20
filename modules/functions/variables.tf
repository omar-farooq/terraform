variable "function_name" {
    type = string
    description = "name of the lambda function"
}

variable "image_uri" {
    type = string
    description = "uri of the image in the public repository"
}

variable "envs" {
    type = map
    description = "additional environment variables"
    default = {
        OMAR = "GREATEST"
    }
}

variable "function_url" {
    type = bool
    description = "Set to true if a function url is required"
    default = false
}

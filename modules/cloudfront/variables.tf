variable "origin_domain" {
    type = string
    description = "If using an S3 bucket then this is the S3 bucket website endpoint"
}

variable "origin_id" {
    type = string
}

variable "cert" {
    type = string
    description = "The certificate of the domain used for the distribution"
}

variable "aliases" {
    type = list
    description = "The domains associated with this distribution"
}

variable "comment" {
    type = string
    description = "Optional comments about this distribution"
    default = ""
}

variable "add_html_ext_arn" {
    type = string
    description = "Add the cloudfront function to add html extensions to pages"
}

variable "contact_lambda" {
    type = string
    description = "Add the lambda for the contact form to be available at the edge"
}

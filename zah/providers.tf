provider "aws" {
  region  = "eu-west-2"
  profile = "default"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

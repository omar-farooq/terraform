terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 5.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "google" {
  project = "zah-website"
  region = "us-east-1"
  credentials = "/home/omar/auth/google-key.json"
}

provider "google-beta" {
  project = "zah-website"
  region = "us-east-1"
  credentials = "/home/omar/auth/google-key.json"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

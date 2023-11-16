terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.25.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.10.0"
    }
  }
}

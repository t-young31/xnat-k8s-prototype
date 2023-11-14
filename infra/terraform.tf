terraform {
  required_version = ">= 1.2.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }

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

provider "cloudflare" {
  # Uses $CLOUDFLARE_API_TOKEN
}

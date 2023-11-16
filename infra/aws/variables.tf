variable "kubeconfig_path" {
  type        = string
  description = "Absolute path to the kubeconfig file that will be created"
}

variable "aws_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "cloudflare_zone_name" {
  type = string
}

variable "cloudflare_subdomain" {
  type = string
}

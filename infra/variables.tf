variable "kubeconfig_path" {
  type = string
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

variable "cloudflare_xnat_subdomain" {
  type = string
}

variable "cloudflare_omero_subdomain" {
  type = string
}

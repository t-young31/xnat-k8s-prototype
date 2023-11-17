module "aws" {
  source = "./aws"

  vpc_id               = var.vpc_id
  subnet_id            = var.subnet_id
  aws_prefix           = var.aws_prefix
  cloudflare_zone_name = var.cloudflare_zone_name
  cloudflare_subdomain = var.cloudflare_xnat_subdomain
  kubeconfig_path      = var.kubeconfig_path

  providers = {
    aws        = aws
    cloudflare = cloudflare

  }
}

#module "xnat" {
#  source = "./xnat" # Note: helm provider needs a name != "xnat". See: https://github.com/hashicorp/terraform-provider-helm/issues/735
#
#  fqdn            = "${cloudflare_record.app["xnat"].name}.${var.cloudflare_zone_name}"
#  kubeconfig_path = var.kubeconfig_path
#
#  providers = {
#    kubernetes = kubernetes
#    helm       = helm
#  }
#
#  depends_on = [module.aws]
#}

module "omero" {
  source = "./omero"

  fqdn            = "${cloudflare_record.app["omero"].name}.${var.cloudflare_zone_name}"
  kubeconfig_path = var.kubeconfig_path

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [module.aws]
}

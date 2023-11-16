module "aws" {
  source = "./aws"

  vpc_id               = var.vpc_id
  subnet_id            = var.subnet_id
  aws_prefix           = var.aws_prefix
  cloudflare_zone_name = var.cloudflare_zone_name
  cloudflare_subdomain = var.cloudflare_subdomain
  kubeconfig_path      = var.kubeconfig_path

  providers = {
    aws        = aws
    cloudflare = cloudflare
  }
}

module "xnat" {
  source = "./_xnat" # Note: helm provider needs a name != "xnat". See: https://github.com/hashicorp/terraform-provider-helm/issues/735

  fqdn            = module.aws.fqdn
  kubeconfig_path = var.kubeconfig_path

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [module.aws]
}

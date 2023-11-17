data "cloudflare_zone" "app" {
  name = var.cloudflare_zone_name
}

resource "cloudflare_record" "app" {
  for_each = {
    xnat  = var.cloudflare_xnat_subdomain,
    omero = var.cloudflare_omero_subdomain
  }

  zone_id = data.cloudflare_zone.app.id
  name    = each.value
  value   = module.aws.server_public_ip
  type    = "A"
  proxied = true
}

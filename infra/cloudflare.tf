data "cloudflare_zone" "app" {
  name = var.cloudflare_zone_name
}

resource "cloudflare_record" "app" {
  zone_id = data.cloudflare_zone.app.id
  name    = var.subdomain
  value   = aws_instance.server.public_ip
  type    = "A"
  proxied = true
}

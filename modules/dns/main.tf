data "cloudflare_zones" "domain" {
  filter {
    name = var.site_domain
  }
}

resource "cloudflare_record" "record" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name = var.record_name
  value = var.record_value
  type = var.record_type
  ttl = 1
  proxied = var.proxied
}

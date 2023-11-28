resource "aws_acm_certificate" "request" {
    domain_name = var.site_domain
    validation_method = "DNS"
}

data "cloudflare_zones" "domain" {
    filter {
        name = var.apex
    }
}

resource "cloudflare_record" "cert_record" {
    for_each = {
        for dvo in aws_acm_certificate.request.domain_validation_options : dvo.domain_name => {
            name = dvo.resource_record_name
            record = dvo.resource_record_value
            type = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    zone_id = data.cloudflare_zones.domain.zones[0].id
    name = each.value.name
    value = each.value.record
    ttl = 1
    type = each.value.type
}

resource "aws_acm_certificate_validation" "domain" {
    certificate_arn = aws_acm_certificate.request.arn
    validation_record_fqdns = [for e in cloudflare_record.cert_record : e.hostname]
}

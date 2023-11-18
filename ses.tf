resource "aws_ses_email_identity" "omar" {
  email = "omrrrrrrr@gmail.com"
}

resource "aws_ses_domain_identity" "omar_earth" {
  domain = "omar.earth"
}

resource "aws_ses_domain_mail_from" "omar_earth" {
  domain           = aws_ses_domain_identity.omar_earth.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.omar_earth.domain}"
}

resource "aws_ses_domain_dkim" "omar_earth" {
  domain = aws_ses_domain_identity.omar_earth.domain
}

resource "cloudflare_record" "omar_earth_ses_domain_mail_from_mx" {
  zone_id  = "3e56238d05818e4f738b7270c76c4c75"
  name     = aws_ses_domain_mail_from.omar_earth.mail_from_domain
  type     = "MX"
  ttl      = "600"
  priority = "10"
  value    = "feedback-smtp.eu-west-2.amazonses.com"
}

resource "cloudflare_record" "omar_earth_ses_domain_mail_from_txt" {
  zone_id = "3e56238d05818e4f738b7270c76c4c75"
  name    = aws_ses_domain_mail_from.omar_earth.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  value   = "v=spf1 include:amazonses.com -all"
}

resource "cloudflare_record" "omar_earth_ses_verification_record" {
  zone_id = "3e56238d05818e4f738b7270c76c4c75"
  name    = "_amazonses.omar.earth"
  type    = "TXT"
  ttl     = "600"
  value   = aws_ses_domain_identity.omar_earth.verification_token
}

resource "cloudflare_record" "omar_earth_amazonses_dkim_record" {
  count   = 3
  zone_id = "3e56238d05818e4f738b7270c76c4c75"
  name    = "${aws_ses_domain_dkim.omar_earth.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  value   = "${aws_ses_domain_dkim.omar_earth.dkim_tokens[count.index]}.dkim.amazonses.com"
}

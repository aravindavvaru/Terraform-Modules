variable "domain" {}
variable "redirect" {}

resource "cloudflare_zone" "zone" {
  zone = var.domain
  type = "full"
}

resource "cloudflare_page_rule" "redirect_1" {
  zone_id  = cloudflare_zone.zone.id
  target   = "http://*${var.domain}/*"
  priority = 1
  status   = "active"

  actions {
    forwarding_url {
      url         = "https://${var.domain}"
      status_code = "301"
    }
  }
}

resource "cloudflare_page_rule" "redirect_www_1" {
  zone_id  = cloudflare_zone.zone.id
  target   = "http://www.${var.domain}/*"
  priority = 2
  status   = "active"

  actions {
    forwarding_url {
      url         = "https://www.${var.domain}"
      status_code = "301"
    }
  }
}

resource "cloudflare_page_rule" "redirect_2" {
  zone_id  = cloudflare_zone.zone.id
  target   = "https://*${var.domain}/*"
  priority = 3
  status   = "active"

  actions {
    forwarding_url {
      url         = var.redirect
      status_code = "301"
    }
  }
}

resource "cloudflare_record" "apex" {
  zone_id = cloudflare_zone.zone.id

  name    = "@"
  type    = "CNAME"
  proxied = true

  value = "domain"
}

resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.zone.id

  name    = "www"
  type    = "CNAME"
  proxied = true

  value = "domain"
}

module "standard_spf" {
  source  = "../spf"
  domain  = var.domain
  zone_id = cloudflare_zone.zone.id
}

resource "cloudflare_zone_settings_override" "override" {
  zone_id = cloudflare_zone.zone.id

  settings {

    min_tls_version = "1.2"
    http3           = "on"

    security_header {
      enabled            = true
      max_age            = 31536000
      include_subdomains = true
      nosniff            = true
    }
  }
}

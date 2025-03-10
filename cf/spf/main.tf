terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
  required_version = ">= 1.0"
}

variable "domain" {}
variable "zone_id" {}

resource "cloudflare_record" "spf_subdomain" {
  zone_id = var.zone_id
  name    = "*.${var.domain}"
  type    = "TXT"
  ttl     = 1800
  value   = "v=spf1"
}

resource "cloudflare_record" "spf_parent" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "TXT"
  ttl     = 1800
  value   = "v=spf1 "
}

resource "cloudflare_record" "mx" {
  zone_id  = var.zone_id
  name     = var.domain
  type     = "MX"
  ttl      = 1
  priority = 0
  value    = "."
}

resource "cloudflare_record" "dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = 1800
  value   = ""
}

resource "cloudflare_record" "dkim" {
  zone_id = var.zone_id
  name    = "*._domainkey.${var.domain}"
  type    = "TXT"
  ttl     = 1800
  value   = "v=DKIM1; p="
}

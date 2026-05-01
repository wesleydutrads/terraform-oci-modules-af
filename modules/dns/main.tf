resource "oci_dns_zone" "this" {
  count          = var.enabled ? 1 : 0
  compartment_id = var.compartment_ocid
  name           = var.zone_name
  zone_type      = "PRIMARY"
  scope          = "GLOBAL"
  freeform_tags  = var.freeform_tags
}

resource "oci_dns_rrset" "this" {
  for_each = var.enabled ? var.records : {}

  zone_name_or_id = oci_dns_zone.this[0].id
  domain          = each.value.domain
  rtype           = each.value.rtype

  dynamic "items" {
    for_each = each.value.rdata

    content {
      domain = each.value.domain
      rdata  = items.value
      rtype  = each.value.rtype
      ttl    = each.value.ttl
    }
  }
}

resource "oci_dns_zone" "this" {
  count          = var.enabled ? 1 : 0
  compartment_id = var.compartment_ocid
  name           = var.zone_name
  zone_type      = "PRIMARY"
  scope          = "GLOBAL"
  freeform_tags  = var.freeform_tags
}

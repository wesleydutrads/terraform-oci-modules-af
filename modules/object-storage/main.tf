data "oci_objectstorage_namespace" "this" {
  count          = var.enabled ? 1 : 0
  compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "this" {
  for_each = var.enabled ? var.bucket_names : {}

  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.this[0].namespace
  name           = each.value
  access_type    = var.access_type
  storage_tier   = var.storage_tier
  freeform_tags  = var.freeform_tags
}

resource "oci_identity_customer_secret_key" "this" {
  count = var.enabled && var.create_customer_secret_key && var.user_ocid != null ? 1 : 0

  display_name = var.customer_secret_key_display_name
  user_id      = var.user_ocid
}

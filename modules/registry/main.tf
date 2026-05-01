resource "oci_artifacts_container_repository" "this" {
  for_each       = var.repositories
  compartment_id = var.compartment_ocid
  display_name   = each.value
  is_public      = var.is_public
}

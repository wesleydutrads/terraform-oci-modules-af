data "oci_identity_compartments" "target" {
  compartment_id = var.tenancy_ocid
  access_level   = "ACCESSIBLE"

  filter {
    name   = "name"
    values = [var.compartment_name]
  }
}

resource "oci_identity_compartment" "target" {
  count          = var.create_compartment_if_missing && length(data.oci_identity_compartments.target.compartments) == 0 ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = var.compartment_name
  description    = "Infrastructure compartment managed by Terraform."
  enable_delete  = true
  freeform_tags  = var.freeform_tags
}

locals {
  compartment_ocid = length(data.oci_identity_compartments.target.compartments) > 0 ? data.oci_identity_compartments.target.compartments[0].id : oci_identity_compartment.target[0].id
}

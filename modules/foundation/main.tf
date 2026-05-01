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

resource "oci_identity_dynamic_group" "node_dns" {
  count          = var.enable_node_dns_instance_principal ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = var.node_dns_dynamic_group_name
  description    = "Compute instances allowed to manage OCI DNS records for Kubernetes automation."
  matching_rule  = "instance.compartment.id = '${local.compartment_ocid}'"
}

resource "oci_identity_policy" "node_dns" {
  count          = var.enable_node_dns_instance_principal ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = "${var.node_dns_dynamic_group_name}_policy"
  description    = "Allow Kubernetes node instance principals to manage DNS records."
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.node_dns[0].name} to use dns-zones in compartment ${var.compartment_name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.node_dns[0].name} to manage dns-records in compartment ${var.compartment_name}"
  ]
}

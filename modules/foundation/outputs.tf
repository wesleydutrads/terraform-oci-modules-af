output "compartment_ocid" {
  description = "Target compartment OCID."
  value       = local.compartment_ocid
}

output "compartment_name" {
  description = "Target compartment name."
  value       = var.compartment_name
}

output "node_dns_dynamic_group_name" {
  description = "Dynamic group name used by node instance principals for DNS automation."
  value       = var.enable_node_dns_instance_principal ? oci_identity_dynamic_group.node_dns[0].name : null
}

output "node_dns_policy_id" {
  description = "IAM policy OCID granting DNS permissions to node instance principals."
  value       = var.enable_node_dns_instance_principal ? oci_identity_policy.node_dns[0].id : null
}

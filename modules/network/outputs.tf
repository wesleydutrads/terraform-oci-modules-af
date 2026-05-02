output "vcn_id" {
  description = "VCN OCID."
  value       = oci_core_vcn.this.id
}

output "api_subnet_id" {
  description = "Kubernetes API subnet OCID."
  value       = oci_core_subnet.api.id
}

output "lb_subnet_id" {
  description = "Load balancer subnet OCID."
  value       = oci_core_subnet.lb.id
}

output "nodes_subnet_id" {
  description = "Worker node subnet OCID."
  value       = oci_core_subnet.nodes.id
}

output "database_subnet_id" {
  description = "Private database subnet OCID, when db_subnet_cidr is set."
  value       = var.db_subnet_cidr != null ? oci_core_subnet.database[0].id : null
}

output "private_route_table_id" {
  description = "Private route table OCID."
  value       = oci_core_route_table.private.id
}

output "public_route_table_id" {
  description = "Public route table OCID."
  value       = oci_core_route_table.public.id
}

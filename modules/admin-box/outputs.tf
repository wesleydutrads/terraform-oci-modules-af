output "instance_id" {
  description = "Admin box instance OCID."
  value       = var.enabled ? oci_core_instance.this[0].id : null
}

output "private_ip" {
  description = "Admin box private IP."
  value       = var.enabled ? oci_core_instance.this[0].private_ip : null
}

output "public_ip" {
  description = "Admin box public IP when assigned."
  value       = var.enabled ? oci_core_instance.this[0].public_ip : null
}

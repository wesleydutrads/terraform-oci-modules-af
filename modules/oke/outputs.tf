output "cluster_id" {
  description = "OKE cluster OCID."
  value       = oci_containerengine_cluster.this.id
}

output "cluster_name" {
  description = "OKE cluster name."
  value       = oci_containerengine_cluster.this.name
}

output "cluster_public_endpoint" {
  description = "Public Kubernetes API endpoint."
  value       = oci_containerengine_cluster.this.endpoints[0].public_endpoint
}

output "node_pool_id" {
  description = "Worker node pool OCID."
  value       = oci_containerengine_node_pool.this.id
}

output "control_plane_nsg_id" {
  description = "Control plane network security group OCID."
  value       = oci_core_network_security_group.control_plane.id
}

output "nodes_nsg_id" {
  description = "Worker nodes network security group OCID."
  value       = oci_core_network_security_group.nodes.id
}

output "kubeconfig_command" {
  description = "OCI CLI command to generate kubeconfig."
  value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.this.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
}

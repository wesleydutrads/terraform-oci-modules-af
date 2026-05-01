output "dns_name_servers" {
  description = "Name servers to delegate at the registrar."
  value       = module.dns.name_servers
}

output "cluster_id" {
  description = "OKE cluster OCID."
  value       = module.oke.cluster_id
}

output "cluster_public_endpoint" {
  description = "Public Kubernetes API endpoint."
  value       = module.oke.cluster_public_endpoint
}

output "kubeconfig_command" {
  description = "Command to generate kubeconfig."
  value       = module.oke.kubeconfig_command
}

output "monitoring_hosts" {
  description = "Monitoring dashboard hostnames."
  value       = module.observability.hosts
}

output "monitoring_token" {
  description = "Shared monitoring token."
  value       = random_password.monitoring_token.result
  sensitive   = true
}

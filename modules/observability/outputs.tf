output "namespace" {
  description = "Observability namespace."
  value       = var.namespace
}

output "hosts" {
  description = "Dashboard hostnames."
  value       = var.hosts
}

output "kiali_service_name" {
  description = "Kiali service name."
  value       = "kiali"
}

output "grafana_service_name" {
  description = "Grafana service name."
  value       = "monitoring-grafana"
}

output "jaeger_service_name" {
  description = "Jaeger query service name."
  value       = "jaeger-query"
}

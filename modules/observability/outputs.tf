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

output "tracing_service_name" {
  description = "Tracing service name."
  value       = var.enable_tempo ? "tempo" : "jaeger"
}

output "loki_service_name" {
  description = "Loki gateway service name."
  value       = "loki-gateway"
}

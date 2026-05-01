output "istio_namespace" {
  description = "Istio namespace."
  value       = local.istio_namespace
}

output "wildcard_secret_name" {
  description = "Wildcard TLS secret name expected by the public Gateway."
  value       = local.wildcard_secret_name
}

output "gateway_name" {
  description = "Public Gateway API object name."
  value       = "public"
}

output "gateway_namespace" {
  description = "Public Gateway API object namespace."
  value       = local.istio_namespace
}

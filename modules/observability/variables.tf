variable "enabled" {
  description = "Install observability components."
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace for observability components."
  type        = string
  default     = "observability"
}

variable "gateway_name" {
  description = "Gateway API parent name."
  type        = string
}

variable "gateway_namespace" {
  description = "Gateway API parent namespace."
  type        = string
}

variable "hosts" {
  description = "Dashboard hostnames."
  type = object({
    kiali   = string
    grafana = string
    jaeger  = string
  })
}

variable "monitoring_token" {
  description = "Shared token required by Istio AuthorizationPolicy."
  type        = string
  sensitive   = true
}

variable "enable_kiali" {
  description = "Install Kiali."
  type        = bool
  default     = true
}

variable "enable_prometheus_stack" {
  description = "Install kube-prometheus-stack."
  type        = bool
  default     = true
}

variable "enable_jaeger" {
  description = "Install Jaeger all-in-one."
  type        = bool
  default     = true
}

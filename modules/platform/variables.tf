variable "enabled" {
  description = "Install platform components."
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Base DNS zone used by the public gateway."
  type        = string
}

variable "acme_email" {
  description = "ACME account email for Let's Encrypt."
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig."
  type        = string
}

variable "kubectl_path" {
  description = "Path to kubectl."
  type        = string
  default     = "kubectl"
}

variable "compartment_ocid" {
  description = "Compartment OCID used by external-dns and DNS01 webhook configuration."
  type        = string
}

variable "region" {
  description = "OCI region."
  type        = string
}

variable "enable_gateway_api_crds" {
  description = "Install Gateway API CRDs."
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Install cert-manager."
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Install external-dns."
  type        = bool
  default     = true
}

variable "enable_istio_ambient" {
  description = "Install Istio ambient components."
  type        = bool
  default     = true
}

variable "enable_public_ingress_gateway" {
  description = "Install public Istio ingress gateway."
  type        = bool
  default     = true
}

variable "public_gateway_allowed_cidrs" {
  description = "CIDRs allowed to reach the public ingress gateway."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_wildcard_certificate" {
  description = "Create ClusterIssuer and wildcard Certificate resources."
  type        = bool
  default     = false
}

variable "dns01_webhook_group_name" {
  description = "cert-manager DNS01 webhook group name."
  type        = string
  default     = "acme.d-n.be"
}

variable "dns01_webhook_solver_name" {
  description = "cert-manager DNS01 webhook solver name."
  type        = string
  default     = "oci"
}

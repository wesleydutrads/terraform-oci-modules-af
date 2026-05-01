variable "oci_profile" {
  description = "OCI CLI profile."
  type        = string
  default     = "DEFAULT"
}

variable "region" {
  description = "OCI region."
  type        = string
}

variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "domain_name" {
  description = "DNS zone name."
  type        = string
}

variable "acme_email" {
  description = "ACME email."
  type        = string
}

variable "api_allowed_cidrs" {
  description = "CIDRs allowed to reach Kubernetes API."
  type        = list(string)
}

variable "ssh_public_key" {
  description = "SSH public key for nodes."
  type        = string
}

variable "kubernetes_version" {
  description = "OKE Kubernetes version."
  type        = string
}

variable "node_image_ocid" {
  description = "OKE node image OCID."
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for worker nodes."
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig after cluster creation."
  type        = string
  default     = "~/.kube/config"
}

variable "enable_platform" {
  description = "Install Kubernetes platform after kubeconfig exists."
  type        = bool
  default     = false
}

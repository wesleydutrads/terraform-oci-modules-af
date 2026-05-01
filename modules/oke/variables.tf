variable "compartment_ocid" {
  description = "Compartment OCID where OKE resources are created."
  type        = string
}

variable "region" {
  description = "OCI region used by the kubeconfig command output."
  type        = string
}

variable "cluster_name" {
  description = "OKE cluster name."
  type        = string
}

variable "vcn_id" {
  description = "VCN OCID."
  type        = string
}

variable "api_subnet_id" {
  description = "Subnet OCID for the public Kubernetes API endpoint."
  type        = string
}

variable "lb_subnet_id" {
  description = "Subnet OCID used by OKE service load balancers."
  type        = string
}

variable "nodes_subnet_id" {
  description = "Private subnet OCID for worker nodes."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use."
  type        = string
}

variable "api_allowed_cidrs" {
  description = "CIDRs allowed to reach the public Kubernetes API endpoint."
  type        = list(string)
}

variable "pods_cidr" {
  description = "Pod CIDR."
  type        = string
}

variable "services_cidr" {
  description = "Services CIDR."
  type        = string
}

variable "node_pool_name" {
  description = "Worker node pool name."
  type        = string
  default     = "np-a1"
}

variable "node_pool_size" {
  description = "Worker node count."
  type        = number
  default     = 2

  validation {
    condition     = var.node_pool_size >= 1 && var.node_pool_size <= 2
    error_message = "Use at most 2 nodes in the Always Free profile."
  }
}

variable "node_shape" {
  description = "Worker node shape."
  type        = string
  default     = "VM.Standard.A1.Flex"

  validation {
    condition     = var.node_shape == "VM.Standard.A1.Flex"
    error_message = "Only VM.Standard.A1.Flex is allowed by this Always Free module."
  }
}

variable "node_ocpus" {
  description = "OCPUs per node."
  type        = number
  default     = 2
}

variable "node_memory_gbs" {
  description = "Memory in GB per node."
  type        = number
  default     = 12
}

variable "node_boot_volume_size_gbs" {
  description = "Boot volume size per node."
  type        = number
  default     = 50
}

variable "ssh_public_key" {
  description = "SSH public key for worker nodes."
  type        = string
}

variable "node_image_ocid" {
  description = "Node image OCID."
  type        = string
}

variable "availability_domain" {
  description = "Availability domain used by the node pool."
  type        = string
}

variable "freeform_tags" {
  description = "Freeform tags applied to supported resources."
  type        = map(string)
  default     = {}
}

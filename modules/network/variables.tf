variable "compartment_ocid" {
  description = "Compartment OCID where network resources are created."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for resource display names."
  type        = string
}

variable "vcn_cidr" {
  description = "VCN CIDR block."
  type        = string
}

variable "api_subnet_cidr" {
  description = "Public subnet CIDR for Kubernetes API endpoint."
  type        = string
}

variable "lb_subnet_cidr" {
  description = "Public subnet CIDR for load balancers."
  type        = string
}

variable "nodes_subnet_cidr" {
  description = "Public subnet CIDR for worker nodes."
  type        = string
}

variable "db_subnet_cidr" {
  description = "Optional private subnet CIDR for managed databases."
  type        = string
  default     = null
}

variable "api_allowed_cidrs" {
  description = "CIDRs allowed to reach the Kubernetes API endpoint."
  type        = list(string)
}

variable "freeform_tags" {
  description = "Freeform tags applied to supported resources."
  type        = map(string)
  default     = {}
}

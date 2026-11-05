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

variable "enable_nodes_nat_gateway" {
  description = "Opt in to a managed NAT Gateway and dedicated worker node routes; review OCI traffic pricing and quotas before enabling."
  type        = bool
  default     = false
  nullable    = false
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

variable "api_security_list_additional_access" {
  description = "Acessos TCP 6443 adicionais exclusivos da security list API, sem ampliar NSGs."
  type = list(object({
    cidr        = string
    description = optional(string)
  }))
  default = []
  validation {
    condition     = alltrue([for rule in var.api_security_list_additional_access : can(cidrnetmask(rule.cidr))])
    error_message = "Cada acesso adicional deve conter CIDR IPv4 válido."
  }
}

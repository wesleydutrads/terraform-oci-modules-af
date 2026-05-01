variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_name" {
  description = "Target compartment name."
  type        = string
}

variable "create_compartment_if_missing" {
  description = "Create the compartment when it does not exist."
  type        = bool
  default     = true
}

variable "freeform_tags" {
  description = "Freeform tags applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "enable_node_dns_instance_principal" {
  description = "Create IAM dynamic group and policy so compute instances in the compartment can manage OCI DNS records."
  type        = bool
  default     = false
}

variable "node_dns_dynamic_group_name" {
  description = "Name of the dynamic group used by node instance principals for DNS automation."
  type        = string
  default     = "oke_nodes_dns"
}

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

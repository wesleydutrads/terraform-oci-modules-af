variable "compartment_ocid" {
  description = "Compartment OCID where repositories are created."
  type        = string
}

variable "repositories" {
  description = "OCIR repository names."
  type        = set(string)
  default     = []
}

variable "is_public" {
  description = "Make repositories public."
  type        = bool
  default     = false
}

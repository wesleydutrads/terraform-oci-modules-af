variable "compartment_ocid" {
  description = "Compartment OCID where DNS resources are created."
  type        = string
}

variable "zone_name" {
  description = "Public DNS zone name, for example example.com."
  type        = string
}

variable "enabled" {
  description = "Create the DNS zone."
  type        = bool
  default     = true
}

variable "freeform_tags" {
  description = "Freeform tags applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "records" {
  description = "DNS RRsets to manage inside the zone."
  type = map(object({
    domain = string
    rtype  = string
    ttl    = number
    rdata  = list(string)
  }))
  default = {}
}

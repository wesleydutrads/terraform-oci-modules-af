variable "enabled" {
  description = "Create the admin box."
  type        = bool
  default     = false
}

variable "compartment_ocid" {
  description = "Compartment OCID."
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for the VM."
  type        = string
}

variable "subnet_ocid" {
  description = "Subnet OCID for the VM."
  type        = string
}

variable "display_name" {
  description = "VM display name."
  type        = string
  default     = "admin-box"
}

variable "shape" {
  description = "VM shape."
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "boot_volume_size_gbs" {
  description = "Boot volume size."
  type        = number
  default     = 50
}

variable "assign_public_ip" {
  description = "Assign public IP to the admin box."
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "SSH public key."
  type        = string
}

variable "image_ocid" {
  description = "Image OCID."
  type        = string
}

variable "freeform_tags" {
  description = "Freeform tags applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "enabled" {
  description = "Create Object Storage resources."
  type        = bool
  default     = true
}

variable "compartment_ocid" {
  description = "Compartment OCID where buckets are created."
  type        = string
}

variable "region" {
  description = "OCI region used to build the S3-compatible endpoint."
  type        = string
}

variable "bucket_names" {
  description = "Bucket names keyed by logical purpose."
  type        = map(string)
  default     = {}
}

variable "access_type" {
  description = "Bucket access type. Keep NoPublicAccess for observability data."
  type        = string
  default     = "NoPublicAccess"
}

variable "storage_tier" {
  description = "Bucket storage tier."
  type        = string
  default     = "Standard"
}

variable "freeform_tags" {
  description = "Freeform tags applied to buckets."
  type        = map(string)
  default     = {}
}

variable "create_customer_secret_key" {
  description = "Create an OCI Customer Secret Key for S3-compatible API access."
  type        = bool
  default     = false
}

variable "customer_secret_key_display_name" {
  description = "Display name for the generated Customer Secret Key."
  type        = string
  default     = "terraform-oci-modules-af-observability"
}

variable "user_ocid" {
  description = "OCI user OCID that owns the Customer Secret Key."
  type        = string
  default     = null
}

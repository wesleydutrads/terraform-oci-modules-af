variable "compartment_ocid" {
  description = "Compartment OCID for optional database resources."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for database display names."
  type        = string
  default     = "oke-af"
}

variable "availability_domain" {
  description = "Availability domain where the MySQL.Free shape has capacity."
  type        = string
  default     = null
}

variable "mysql_subnet_id" {
  description = "Private subnet OCID for MySQL HeatWave Always Free."
  type        = string
  default     = null
}

variable "vcn_id" {
  description = "VCN OCID used to attach optional private DNS records."
  type        = string
  default     = null
}

variable "enable_autonomous_database" {
  description = "Create an Autonomous Database Always Free resource."
  type        = bool
  default     = false
}

variable "enable_mysql_heatwave" {
  description = "Create a MySQL HeatWave Always Free resource."
  type        = bool
  default     = false
}

variable "mysql_admin_username" {
  description = "MySQL admin username."
  type        = string
  default     = "admin"
}

variable "mysql_admin_password" {
  description = "Optional MySQL admin password. If null, the module generates one."
  type        = string
  default     = null
  sensitive   = true
}

variable "mysql_shape_name" {
  description = "MySQL shape. Keep MySQL.Free to stay inside Always Free."
  type        = string
  default     = "MySQL.Free"

  validation {
    condition     = var.mysql_shape_name == "MySQL.Free"
    error_message = "Only MySQL.Free is allowed by this module to preserve Always Free defaults."
  }
}

variable "mysql_storage_size_gb" {
  description = "MySQL data storage size in GB."
  type        = number
  default     = 50
}

variable "enable_mysql_private_dns" {
  description = "Create an OCI Private DNS zone and A record for the MySQL endpoint."
  type        = bool
  default     = false
}

variable "mysql_private_dns_zone_name" {
  description = "Private DNS zone name for the MySQL endpoint."
  type        = string
  default     = "platform.internal"
}

variable "mysql_private_dns_zone_id" {
  description = "Existing OCI Private DNS zone OCID. When set, the module reuses it instead of creating a zone."
  type        = string
  default     = null
}

variable "mysql_private_dns_record_name" {
  description = "Record name inside mysql_private_dns_zone_name."
  type        = string
  default     = "mysql"
}

variable "enable_nosql_tables" {
  description = "Create NoSQL Always Free tables."
  type        = bool
  default     = false
}

variable "freeform_tags" {
  description = "Freeform tags applied to supported resources."
  type        = map(string)
  default     = {}
}

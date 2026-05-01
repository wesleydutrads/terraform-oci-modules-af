variable "compartment_ocid" {
  description = "Compartment OCID for optional database resources."
  type        = string
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

variable "enable_nosql_tables" {
  description = "Create NoSQL Always Free tables."
  type        = bool
  default     = false
}

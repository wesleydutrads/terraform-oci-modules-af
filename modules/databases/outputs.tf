output "enabled_services" {
  description = "Database service flags enabled by the caller."
  value = {
    autonomous_database = var.enable_autonomous_database
    mysql_heatwave      = var.enable_mysql_heatwave
    nosql_tables        = var.enable_nosql_tables
  }
}

output "mysql_db_system_id" {
  description = "MySQL DB system OCID."
  value       = var.enable_mysql_heatwave ? oci_mysql_mysql_db_system.always_free[0].id : null
}

output "mysql_endpoint" {
  description = "MySQL endpoint details for Kubernetes applications."
  value = var.enable_mysql_heatwave ? {
    host       = oci_mysql_mysql_db_system.always_free[0].endpoints[0].ip_address
    port       = oci_mysql_mysql_db_system.always_free[0].endpoints[0].port
    x_port     = oci_mysql_mysql_db_system.always_free[0].endpoints[0].port_x
    shape_name = oci_mysql_mysql_db_system.always_free[0].shape_name
  } : null
}

output "mysql_private_fqdn" {
  description = "OCI Private DNS FQDN for the MySQL endpoint."
  value       = var.enable_mysql_heatwave && var.enable_mysql_private_dns ? local.mysql_private_fqdn : null
}

output "mysql_private_dns_zone_id" {
  description = "OCI Private DNS zone OCID for the MySQL endpoint."
  value       = var.enable_mysql_heatwave && var.enable_mysql_private_dns ? local.mysql_private_zone_id : null
}

output "mysql_admin_username" {
  description = "MySQL admin username."
  value       = var.enable_mysql_heatwave ? var.mysql_admin_username : null
}

output "mysql_admin_password" {
  description = "MySQL admin password."
  value       = var.enable_mysql_heatwave ? local.mysql_admin_password : null
  sensitive   = true
}

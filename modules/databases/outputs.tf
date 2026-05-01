output "enabled_services" {
  description = "Database service flags enabled by the caller."
  value = {
    autonomous_database = var.enable_autonomous_database
    mysql_heatwave      = var.enable_mysql_heatwave
    nosql_tables        = var.enable_nosql_tables
  }
}

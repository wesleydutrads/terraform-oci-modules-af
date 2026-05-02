resource "random_password" "mysql_admin" {
  count = var.enable_mysql_heatwave && var.mysql_admin_password == null ? 1 : 0

  length           = 24
  special          = true
  override_special = "#_-"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

locals {
  mysql_admin_password = var.mysql_admin_password != null ? var.mysql_admin_password : try(random_password.mysql_admin[0].result, null)
}

resource "oci_mysql_mysql_db_system" "always_free" {
  count = var.enable_mysql_heatwave ? 1 : 0

  compartment_id          = var.compartment_ocid
  availability_domain     = var.availability_domain
  subnet_id               = var.mysql_subnet_id
  shape_name              = var.mysql_shape_name
  admin_username          = var.mysql_admin_username
  admin_password          = local.mysql_admin_password
  data_storage_size_in_gb = var.mysql_storage_size_gb
  display_name            = "${var.name_prefix}-mysql-af"
  description             = "Always Free MySQL DB system for Kubernetes platform applications."
  is_highly_available     = false
  freeform_tags           = var.freeform_tags

  deletion_policy {
    final_backup = "SKIP_FINAL_BACKUP"
  }

  lifecycle {
    precondition {
      condition     = var.availability_domain != null && var.mysql_subnet_id != null
      error_message = "availability_domain and mysql_subnet_id are required when enable_mysql_heatwave=true."
    }
  }
}

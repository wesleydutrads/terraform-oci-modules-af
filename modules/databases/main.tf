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
  mysql_private_fqdn   = "${var.mysql_private_dns_record_name}.${var.mysql_private_dns_zone_name}"
  mysql_private_zone_id = var.mysql_private_dns_zone_id != null ? var.mysql_private_dns_zone_id : (
    var.enable_mysql_heatwave && var.enable_mysql_private_dns ? oci_dns_zone.mysql_private[0].id : null
  )
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

data "oci_core_vcn_dns_resolver_association" "this" {
  count = var.enable_mysql_heatwave && var.enable_mysql_private_dns ? 1 : 0

  vcn_id = var.vcn_id

  lifecycle {
    precondition {
      condition     = var.vcn_id != null
      error_message = "vcn_id is required when enable_mysql_private_dns=true."
    }
  }
}

data "oci_dns_resolver" "this" {
  count = var.enable_mysql_heatwave && var.enable_mysql_private_dns ? 1 : 0

  resolver_id = data.oci_core_vcn_dns_resolver_association.this[0].dns_resolver_id
  scope       = "PRIVATE"
}

resource "oci_dns_zone" "mysql_private" {
  count = var.enable_mysql_heatwave && var.enable_mysql_private_dns && var.mysql_private_dns_zone_id == null ? 1 : 0

  compartment_id = var.compartment_ocid
  name           = var.mysql_private_dns_zone_name
  scope          = "PRIVATE"
  view_id        = data.oci_dns_resolver.this[0].default_view_id
  zone_type      = "PRIMARY"
  freeform_tags  = var.freeform_tags
}

resource "oci_dns_rrset" "mysql_private" {
  count = var.enable_mysql_heatwave && var.enable_mysql_private_dns ? 1 : 0

  zone_name_or_id = local.mysql_private_zone_id
  domain          = local.mysql_private_fqdn
  rtype           = "A"

  items {
    domain = local.mysql_private_fqdn
    rdata  = oci_mysql_mysql_db_system.always_free[0].endpoints[0].ip_address
    rtype  = "A"
    ttl    = 60
  }
}

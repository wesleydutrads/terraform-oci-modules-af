# databases

Creates optional Always Free database resources.

## MySQL HeatWave Always Free

Set `enable_mysql_heatwave=true` to create one `oci_mysql_mysql_db_system`
using shape `MySQL.Free`. The caller must pass a private subnet OCID and an
availability domain with free-shape capacity.

```hcl
module "databases" {
  source = "../modules/databases"

  compartment_ocid      = module.foundation.compartment_ocid
  name_prefix           = "oke-af"
  enable_mysql_heatwave = true
  availability_domain   = local.ad_name
  mysql_subnet_id       = module.network.database_subnet_id
}
```

The module generates the admin password when `mysql_admin_password=null`.
Outputs expose `mysql_endpoint`, `mysql_admin_username`, and the sensitive
`mysql_admin_password` so Kubernetes application modules can create dedicated
schemas and users.

Backups are disabled by default. Enable only after validating current Always
Free limits and the Terraform plan.

## Private DNS

Set `enable_mysql_private_dns=true` to create an OCI Private DNS `A` record for
the MySQL private endpoint. By default the module creates a dedicated private
zone such as `platform.internal` and publishes `mysql.platform.internal`.

```hcl
module "databases" {
  source = "../modules/databases"

  enable_mysql_heatwave         = true
  enable_mysql_private_dns      = true
  mysql_private_dns_zone_name   = "platform.internal"
  mysql_private_dns_record_name = "mysql"
}
```

The module can also reuse an existing private zone when
`mysql_private_dns_zone_id` is set. OCI-created subnet zones such as
`dbsubnet.<vcn>.oraclevcn.com` can be protected by OCI; protected zones reject
custom RRSet updates with `409 Operation not allowed on protected resource`.
Use a dedicated private zone for application-owned records when that happens.

## Guardrails

- databases are disabled by default
- `mysql_shape_name` is validated as `MySQL.Free`
- no public subnet is created here; use the network module database subnet
- application-owned private DNS records should use a writable private zone
- outputs are designed for downstream app-specific credentials

## References

- [OCI MySQL Always Free DB system](https://docs.oracle.com/en-us/iaas/mysql-database/doc/creating-always-free-db-system.html)
- [Terraform OCI MySQL DB system](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/latest/docs/r/mysql_mysql_db_system.html)
- [Terraform OCI DNS RRSet](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/latest/docs/r/dns_rrset.html)

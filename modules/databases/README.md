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

## Guardrails

- databases are disabled by default
- `mysql_shape_name` is validated as `MySQL.Free`
- no public subnet is created here; use the network module database subnet
- outputs are designed for downstream app-specific credentials

## References

- [OCI MySQL Always Free DB system](https://docs.oracle.com/en-us/iaas/mysql-database/doc/creating-always-free-db-system.html)
- [Terraform OCI MySQL DB system](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/latest/docs/r/mysql_mysql_db_system.html)

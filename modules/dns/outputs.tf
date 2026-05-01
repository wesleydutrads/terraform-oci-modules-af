output "zone_id" {
  description = "DNS zone OCID."
  value       = var.enabled ? oci_dns_zone.this[0].id : null
}

output "zone_name" {
  description = "DNS zone name."
  value       = var.zone_name
}

output "name_servers" {
  description = "Name servers to delegate at the registrar."
  value       = var.enabled ? oci_dns_zone.this[0].nameservers : []
}

output "scope" {
  description = "DNS zone scope."
  value       = var.enabled ? oci_dns_zone.this[0].scope : null
}

output "records" {
  description = "Managed DNS RRsets."
  value = {
    for name, rrset in oci_dns_rrset.this : name => {
      domain = rrset.domain
      rtype  = rrset.rtype
      items  = rrset.items
    }
  }
}

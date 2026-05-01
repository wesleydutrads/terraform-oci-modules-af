# dns

Creates an optional OCI public DNS zone and manages explicit DNS records.

## Behavior

- Creates the public zone when `enabled=true`.
- Returns OCI name servers for registrar delegation.
- Optionally manages RRsets such as dashboard A records.
- Keeps real domains, IPs, and environment values in the root module.

## Example

```hcl
module "dns" {
  source = "../modules/dns"

  enabled          = true
  compartment_ocid = module.foundation.compartment_ocid
  zone_name        = "example.com"

  records = {
    grafana = {
      domain = "grafana.example.com"
      rtype  = "A"
      ttl    = 60
      rdata  = ["203.0.113.20"]
    }
  }
}
```

Use this module for records that need deterministic targets. If a Kubernetes
Gateway reports both private and public addresses, prefer explicit records from
Terraform instead of allowing `external-dns` to publish both.

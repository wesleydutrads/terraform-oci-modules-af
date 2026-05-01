# platform

Installs the shared Kubernetes platform layer for an OCI OKE cluster.

## Components

- Gateway API CRDs
- cert-manager
- optional OCI DNS01 cert-manager webhook
- external-dns
- Metrics Server
- Istio ambient mode
- public Istio ingress gateway backed by an OCI Network Load Balancer
- optional wildcard TLS certificate and HTTPS Gateway listener

## Inputs

The caller must provide the base domain, ACME email, OCI region, compartment
OCID, kubeconfig path, and public ingress allowlist. Keep environment-specific
values in the root module, not in this module.

Example:

```hcl
module "platform" {
  source = "../modules/platform"

  domain_name                  = "example.com"
  acme_email                   = "admin@example.com"
  compartment_ocid             = module.foundation.compartment_ocid
  region                       = "us-phoenix-1"
  kubeconfig_path              = "~/.kube/config"
  public_gateway_allowed_cidrs = ["203.0.113.10/32"]
  enable_wildcard_certificate  = true
}
```

## DNS and TLS

When `enable_wildcard_certificate=true`, the module creates a ClusterIssuer and
a wildcard Certificate for `*.domain_name`. The HTTPS Gateway listener is applied
only after the certificate is ready.

The OCI DNS01 webhook expects the OKE nodes to have permission to manage TXT
records in the target zone, typically through instance principal policies.

## Outputs

The module returns the Gateway name, Gateway namespace, Istio namespace, Gateway
Service name, and wildcard secret name so root modules can wire DNS records and
observability routes.

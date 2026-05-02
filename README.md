# terraform-oci-modules-af

Terraform modules for building Oracle Cloud Infrastructure environments focused on Always Free resources.

The goal is to provide composable, documented OCI/IaaS modules for Kubernetes
labs and small platform environments that stay inside OCI Always Free limits by
default.

## Principles

- Modules are reusable and contain no real domain names, OCIDs, emails, or personal IPs.
- Example root modules pass all environment-specific values.
- Defaults are conservative and cost-aware.
- Every module exposes useful outputs.
- Paid resources must be opt-in and clearly documented.

## Modules

- [`foundation`](modules/foundation/): compartments, common tags, IAM helpers, and cost guardrails.
- [`network`](modules/network/): VCN, public API/LB/node subnets, Internet Gateway, Service Gateway, route tables, NSGs.
- [`dns`](modules/dns/): OCI public DNS zones and outputs for registrar delegation.
- [`oke`](modules/oke/): OKE Basic cluster and A1 Flex worker pools.
- [`object-storage`](modules/object-storage/): buckets and S3-compatible credentials for logs and traces.
- [`registry`](modules/registry/): OCI Container Registry repositories and IAM policies.
- [`admin-box`](modules/admin-box/): optional E2.1.Micro administration VM.
- [`databases`](modules/databases/): optional MySQL HeatWave Always Free integration.

## Kubernetes Tools

Kubernetes applications and cluster tools moved to
[`terraform-kubernetes-platform-tools`](../terraform-kubernetes-platform-tools/README.md).
That repository owns Helm/Kubernetes modules such as Istio, cert-manager,
ExternalDNS, observability, Argo CD, Keycloak runtime, and Keycloak OIDC
configuration.

## Documentation Map

- [OKE platform example](examples/oke-platform/README.md): root module example showing how the modules fit together.
- [Consumer project](../oci-oke-always-free/README.md): complete runnable implementation using these modules.
- [Consumer architecture](../oci-oke-always-free/docs/architecture.md): Mermaid diagrams for the full environment.
- [Consumer usage guide](../oci-oke-always-free/docs/manual-de-uso.md): phased execution and operational access.
- [Kubernetes tools modules](../terraform-kubernetes-platform-tools/README.md): in-cluster platform components.
- [Contribution guide](CONTRIBUTING.md): validation and contribution workflow.

## Repository Status

This repository is being prepared as a public module library. APIs may change before the first tagged release.

## License

MIT. See [LICENSE](LICENSE).

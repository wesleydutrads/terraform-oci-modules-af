# terraform-oci-modules-af

Terraform modules for building Oracle Cloud Infrastructure environments focused on Always Free resources.

The goal is to provide composable, documented modules for Kubernetes labs and small platform environments that stay inside OCI Always Free limits by default.

## Principles

- Modules are reusable and contain no real domain names, OCIDs, emails, or personal IPs.
- Example root modules pass all environment-specific values.
- Defaults are conservative and cost-aware.
- Every module exposes useful outputs.
- Paid resources must be opt-in and clearly documented.

## Planned Modules

- [`foundation`](modules/foundation/): compartments, common tags, IAM helpers, and cost guardrails.
- [`network`](modules/network/): VCN, public API/LB/node subnets, Internet Gateway, Service Gateway, route tables, NSGs.
- [`dns`](modules/dns/): OCI public DNS zones and outputs for registrar delegation.
- [`oke`](modules/oke/): OKE Basic cluster and A1 Flex worker pools.
- [`platform`](modules/platform/): cert-manager, external-dns, Istio ambient, Gateway API, wildcard ingress, waypoint, and Bookinfo.
- [`observability`](modules/observability/): Kiali, Prometheus/Grafana, Loki, Tempo, and protected routes.
- [`object-storage`](modules/object-storage/): buckets and S3-compatible credentials for logs and traces.
- [`registry`](modules/registry/): OCI Container Registry repositories and IAM policies.
- [`admin-box`](modules/admin-box/): optional E2.1.Micro administration VM.
- [`databases`](modules/databases/): optional Always Free database integrations.

## Documentation Map

- [OKE platform example](examples/oke-platform/README.md): root module example showing how the modules fit together.
- [Consumer project](../oci-oke-always-free/README.md): complete runnable implementation using these modules.
- [Consumer architecture](../oci-oke-always-free/docs/architecture.md): Mermaid diagrams for the full environment.
- [Consumer usage guide](../oci-oke-always-free/docs/manual-de-uso.md): phased execution and operational access.
- [Contribution guide](CONTRIBUTING.md): validation and contribution workflow.

## Repository Status

This repository is being prepared as a public module library. APIs may change before the first tagged release.

## License

MIT. See [LICENSE](LICENSE).

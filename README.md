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

- `foundation`: compartments, common tags, IAM helpers, and cost guardrails.
- `network`: VCN, public/private subnets, gateways, route tables, NSGs.
- `dns`: OCI public DNS zones and outputs for registrar delegation.
- `oke`: OKE Basic cluster and A1 Flex worker pools.
- `platform`: cert-manager, external-dns, Istio ambient, Gateway API, and wildcard ingress.
- `observability`: Kiali, Prometheus/Grafana, Jaeger, and optional logs/traces.
- `registry`: OCI Container Registry repositories and IAM policies.
- `admin-box`: optional E2.1.Micro administration VM.
- `databases`: optional Always Free database integrations.

## Repository Status

This repository is being prepared as a public module library. APIs may change before the first tagged release.

## License

MIT. See [LICENSE](LICENSE).

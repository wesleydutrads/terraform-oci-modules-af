# Changelog

## Unreleased

### Moved

- Moved Kubernetes tool modules to `terraform-kubernetes-platform-tools`:
  `platform`, `observability`, `argocd`, `keycloak`, and `keycloak-config`.
  Decision: OCI infrastructure and in-cluster tools have different providers,
  validation flows, and lifecycles.

### Added

- Added optional private database subnet support in the network module.
  Decision: managed databases should not be placed in public subnets.
- Added MySQL HeatWave Always Free support in the databases module using
  `MySQL.Free`. Decision: relational persistence for Keycloak must stay opt-in
  and guarded by shape validation.
- Added optional MySQL private DNS support in the databases module, including
  support for a dedicated private zone or a caller-provided private zone OCID.
  Decision: application-owned database records need writable private DNS; OCI
  protected subnet zones can reject custom RRSet updates.

### Changed

- Repository scope is now OCI/IaaS only. Helm, Kubernetes, and application
  provider modules live in the Kubernetes tools repository.

### Documentation

- Documented the repository boundary between OCI infrastructure modules and
  Kubernetes platform tools.

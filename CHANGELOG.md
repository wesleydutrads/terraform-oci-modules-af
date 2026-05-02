# Changelog

## Unreleased

### Added

- Added Gateway API support to ExternalDNS through the `gateway-httproute`
  source. Decision: DNS should follow application HTTPRoutes when the public
  Gateway is annotated with the public NLB IP.
- Added optional public Bookinfo route and output. Decision: labs need a
  repeatable test application without creating another LoadBalancer.
- Added optional private database subnet support in the network module.
  Decision: managed databases should not be placed in public subnets.
- Added MySQL HeatWave Always Free support in the databases module using
  `MySQL.Free`. Decision: relational persistence for Keycloak must stay opt-in
  and guarded by shape validation.
- Added Keycloak runtime module with MySQL bootstrap, HTTPRoute, ServiceEntry,
  and conservative resource limits. Decision: deploy runtime separately from
  identity configuration to avoid Terraform provider bootstrap cycles.
- Added `keycloak-config` module using the official `keycloak/keycloak`
  provider `>= 5.7.0`. Decision: realm, groups, OIDC clients, and protocol
  mappers should be declarative and updateable after Keycloak is online.
- Added optional OIDC wiring for Argo CD, Grafana, and Kiali. Decision: each app
  uses its own client because redirect URIs and secrets are different.

### Changed

- ExternalDNS chart version is now configurable and defaults to `1.21.1`.
- Observability can now accept separate Grafana and Kiali OIDC client secrets.
- Argo CD can now consume an external OIDC issuer and client secret while
  preserving the local admin bootstrap option.

### Documentation

- Documented MySQL, Keycloak, ExternalDNS Gateway API, Bookinfo, OIDC phases,
  and hands-on workshop flows.

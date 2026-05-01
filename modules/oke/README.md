# oke

Creates an OKE Basic cluster and an ARM A1 Flex worker node pool for Always Free-oriented environments.

The module validates the default Always Free budget of 4 OCPU and 24 GB RAM across the node pool.

Default sizing is two `VM.Standard.A1.Flex` nodes with 2 OCPUs and 12 GB RAM each. The API endpoint is public but restricted by `api_allowed_cidrs`.

The module creates NSGs for:

- administrator access to the Kubernetes API on TCP 6443
- worker-to-control-plane communication on TCP 6443 and TCP 12250
- control-plane-to-worker communication
- ICMP path discovery
- worker outbound traffic

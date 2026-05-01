# network

Creates the VCN layout used by OKE Always Free environments:

- public API subnet for the OKE control plane endpoint
- public load balancer subnet for Kubernetes `LoadBalancer` services
- public worker node subnet routed through the Internet Gateway
- Service Gateway for private access to Oracle services

The module intentionally does not create a NAT Gateway. Worker nodes receive public egress through the Internet Gateway to avoid NAT cost while keeping inbound access constrained by security lists and NSGs.

OKE network rules include the control-plane-to-worker paths required by Oracle guidance: TCP 6443, TCP 12250, and ICMP path discovery.

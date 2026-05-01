locals {
  istio_namespace      = "istio-system"
  wildcard_secret_name = "wildcard-${replace(var.domain_name, ".", "-")}-tls"
}

resource "null_resource" "gateway_api_crds" {
  count = var.enabled && var.enable_gateway_api_crds ? 1 : 0

  triggers = {
    version = "v1.3.0"
  }

  provisioner "local-exec" {
    command = "${var.kubectl_path} --kubeconfig=${var.kubeconfig_path} apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${self.triggers.version}/standard-install.yaml"
  }
}

resource "kubernetes_namespace_v1" "cert_manager" {
  count = var.enabled && var.enable_cert_manager ? 1 : 0

  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace_v1" "istio_system" {
  count = var.enabled && var.enable_istio_ambient ? 1 : 0

  metadata {
    name = local.istio_namespace
  }
}

resource "helm_release" "cert_manager" {
  count            = var.enabled && var.enable_cert_manager ? 1 : 0
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = kubernetes_namespace_v1.cert_manager[0].metadata[0].name
  version          = "v1.20.2"
  create_namespace = false

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    }
  ]
}

resource "helm_release" "external_dns" {
  count      = var.enabled && var.enable_external_dns ? 1 : 0
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "1.15.2"

  values = [
    yamlencode({
      provider = "oci"
      policy   = "sync"
      sources  = ["service", "gateway-httproute"]
      domainFilters = [
        var.domain_name
      ]
      extraArgs = [
        "--oci-auth-instance-principal",
        "--oci-compartment-ocid=${var.compartment_ocid}",
        "--oci-zone-scope=GLOBAL"
      ]
    })
  ]
}

resource "helm_release" "istio_base" {
  count            = var.enabled && var.enable_istio_ambient ? 1 : 0
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = kubernetes_namespace_v1.istio_system[0].metadata[0].name
  create_namespace = false
}

resource "helm_release" "istiod" {
  count      = var.enabled && var.enable_istio_ambient ? 1 : 0
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace_v1.istio_system[0].metadata[0].name

  set = [
    {
      name  = "profile"
      value = "ambient"
    }
  ]

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_cni" {
  count      = var.enabled && var.enable_istio_ambient ? 1 : 0
  name       = "istio-cni"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  namespace  = kubernetes_namespace_v1.istio_system[0].metadata[0].name

  set = [
    {
      name  = "profile"
      value = "ambient"
    }
  ]

  depends_on = [helm_release.istiod]
}

resource "helm_release" "ztunnel" {
  count      = var.enabled && var.enable_istio_ambient ? 1 : 0
  name       = "ztunnel"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "ztunnel"
  namespace  = kubernetes_namespace_v1.istio_system[0].metadata[0].name

  depends_on = [helm_release.istio_cni]
}

resource "helm_release" "public_ingressgateway" {
  count      = var.enabled && var.enable_public_ingress_gateway ? 1 : 0
  name       = "public-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace_v1.istio_system[0].metadata[0].name

  values = [
    yamlencode({
      service = {
        type = "LoadBalancer"
        annotations = {
          "oci.oraclecloud.com/load-balancer-type" = "nlb"
        }
        loadBalancerSourceRanges = var.public_gateway_allowed_cidrs
      }
    })
  ]

  depends_on = [helm_release.istiod]
}

resource "kubernetes_manifest" "letsencrypt_prod" {
  count = var.enabled && var.enable_wildcard_certificate ? 1 : 0

  manifest = yamldecode(<<-YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-prod
    spec:
      acme:
        email: ${var.acme_email}
        server: https://acme-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: letsencrypt-prod-account-key
        solvers:
          - selector:
              dnsZones:
                - ${var.domain_name}
            dns01:
              webhook:
                groupName: ${var.dns01_webhook_group_name}
                solverName: ${var.dns01_webhook_solver_name}
                config:
                  compartmentOCID: ${var.compartment_ocid}
                  region: ${var.region}
    YAML
  )

  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "wildcard_certificate" {
  count = var.enabled && var.enable_wildcard_certificate ? 1 : 0

  manifest = yamldecode(<<-YAML
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: wildcard-${replace(var.domain_name, ".", "-")}
      namespace: ${local.istio_namespace}
    spec:
      secretName: ${local.wildcard_secret_name}
      issuerRef:
        name: letsencrypt-prod
        kind: ClusterIssuer
      dnsNames:
        - ${var.domain_name}
        - "*.${var.domain_name}"
    YAML
  )

  depends_on = [kubernetes_manifest.letsencrypt_prod]
}

resource "kubernetes_manifest" "public_gateway" {
  count = var.enabled && var.enable_public_ingress_gateway ? 1 : 0

  manifest = yamldecode(<<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: Gateway
    metadata:
      name: public
      namespace: ${local.istio_namespace}
      annotations:
        external-dns.alpha.kubernetes.io/hostname: "*.${var.domain_name}"
    spec:
      gatewayClassName: istio
      listeners:
        - name: http
          hostname: "*.${var.domain_name}"
          port: 80
          protocol: HTTP
          allowedRoutes:
            namespaces:
              from: All
        - name: https
          hostname: "*.${var.domain_name}"
          port: 443
          protocol: HTTPS
          tls:
            mode: Terminate
            certificateRefs:
              - name: ${local.wildcard_secret_name}
          allowedRoutes:
            namespaces:
              from: All
    YAML
  )

  depends_on = [
    null_resource.gateway_api_crds,
    helm_release.public_ingressgateway
  ]
}

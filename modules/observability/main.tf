resource "kubernetes_namespace_v1" "this" {
  count = var.enabled ? 1 : 0

  metadata {
    name = var.namespace
    labels = {
      "istio.io/dataplane-mode" = "ambient"
    }
  }
}

resource "helm_release" "prometheus_stack" {
  count            = var.enabled && var.enable_prometheus_stack ? 1 : 0
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = kubernetes_namespace_v1.this[0].metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      grafana = {
        enabled       = true
        adminPassword = var.monitoring_token
      }
      alertmanager = {
        enabled = false
      }
      prometheus = {
        prometheusSpec = {
          retention = "12h"
        }
      }
    })
  ]
}

resource "helm_release" "jaeger" {
  count            = var.enabled && var.enable_jaeger ? 1 : 0
  name             = "jaeger"
  repository       = "https://jaegertracing.github.io/helm-charts"
  chart            = "jaeger"
  namespace        = kubernetes_namespace_v1.this[0].metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      provisionDataStore = {
        cassandra = false
      }
      allInOne = {
        enabled = true
      }
      storage = {
        type = "memory"
      }
      agent = {
        enabled = false
      }
      collector = {
        enabled = false
      }
      query = {
        enabled = false
      }
    })
  ]
}

resource "helm_release" "kiali" {
  count            = var.enabled && var.enable_kiali ? 1 : 0
  name             = "kiali"
  repository       = "https://kiali.org/helm-charts"
  chart            = "kiali-server"
  namespace        = kubernetes_namespace_v1.this[0].metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      auth = {
        strategy = "anonymous"
      }
      external_services = {
        prometheus = {
          url = "http://monitoring-kube-prometheus-prometheus.${var.namespace}.svc:9090"
        }
        grafana = {
          enabled        = var.enable_prometheus_stack
          in_cluster_url = "http://monitoring-grafana.${var.namespace}.svc"
          url            = "https://${var.hosts.grafana}"
        }
        tracing = {
          enabled        = var.enable_jaeger
          in_cluster_url = "http://jaeger-query.${var.namespace}.svc:16686"
          url            = "https://${var.hosts.jaeger}"
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "token_policy" {
  count = var.enabled ? 1 : 0

  manifest = yamldecode(<<-YAML
    apiVersion: security.istio.io/v1
    kind: AuthorizationPolicy
    metadata:
      name: monitoring-token-required
      namespace: ${var.gateway_namespace}
    spec:
      targetRefs:
        - group: gateway.networking.k8s.io
          kind: Gateway
          name: ${var.gateway_name}
      action: DENY
      rules:
        - to:
            - operation:
                hosts:
                  - ${var.hosts.kiali}
                  - ${var.hosts.grafana}
                  - ${var.hosts.jaeger}
          when:
            - key: request.headers[x-monitoring-token]
              notValues:
                - ${var.monitoring_token}
    YAML
  )
}

resource "kubernetes_manifest" "kiali_route" {
  count = var.enabled && var.enable_kiali ? 1 : 0

  manifest = yamldecode(<<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: kiali
      namespace: ${var.namespace}
    spec:
      parentRefs:
        - name: ${var.gateway_name}
          namespace: ${var.gateway_namespace}
      hostnames:
        - ${var.hosts.kiali}
      rules:
        - backendRefs:
            - name: kiali
              port: 20001
    YAML
  )
}

resource "kubernetes_manifest" "grafana_route" {
  count = var.enabled && var.enable_prometheus_stack ? 1 : 0

  manifest = yamldecode(<<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: grafana
      namespace: ${var.namespace}
    spec:
      parentRefs:
        - name: ${var.gateway_name}
          namespace: ${var.gateway_namespace}
      hostnames:
        - ${var.hosts.grafana}
      rules:
        - backendRefs:
            - name: monitoring-grafana
              port: 80
    YAML
  )
}

resource "kubernetes_manifest" "jaeger_route" {
  count = var.enabled && var.enable_jaeger ? 1 : 0

  manifest = yamldecode(<<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: jaeger
      namespace: ${var.namespace}
    spec:
      parentRefs:
        - name: ${var.gateway_name}
          namespace: ${var.gateway_namespace}
      hostnames:
        - ${var.hosts.jaeger}
      rules:
        - backendRefs:
            - name: jaeger-query
              port: 16686
    YAML
  )
}

locals {
  kubeconfig_path        = pathexpand(var.kubeconfig_path)
  tracing_host           = var.hosts.tracing
  tracing_backend        = var.enable_tempo ? "tempo" : "jaeger"
  token_policy_manifest  = <<-YAML
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
                  - ${local.tracing_host}
          when:
            - key: request.headers[x-monitoring-token]
              notValues:
                - ${var.monitoring_token}
    YAML
  kiali_route_manifest   = <<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: kiali
      namespace: ${var.namespace}
%{if var.external_dns_target != null~}
      annotations:
        external-dns.alpha.kubernetes.io/target: ${var.external_dns_target}
%{endif~}
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
  grafana_route_manifest = <<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: grafana
      namespace: ${var.namespace}
%{if var.external_dns_target != null~}
      annotations:
        external-dns.alpha.kubernetes.io/target: ${var.external_dns_target}
%{endif~}
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
  tracing_route_manifest = <<-YAML
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: tracing
      namespace: ${var.namespace}
%{if var.external_dns_target != null~}
      annotations:
        external-dns.alpha.kubernetes.io/target: ${var.external_dns_target}
%{endif~}
    spec:
      parentRefs:
        - name: ${var.gateway_name}
          namespace: ${var.gateway_namespace}
      hostnames:
        - ${local.tracing_host}
      rules:
        - backendRefs:
            - name: ${local.tracing_backend}
              port: ${var.enable_tempo ? 3200 : 16686}
    YAML
}

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
        persistence = {
          enabled          = var.enable_grafana_persistence
          storageClassName = var.monitoring_storage_class_name
          size             = var.grafana_storage_size
        }
        additionalDataSources = concat(
          var.enable_loki ? [
            {
              name      = "Loki"
              uid       = "loki"
              type      = "loki"
              access    = "proxy"
              url       = "http://loki-gateway.${var.namespace}.svc.cluster.local"
              isDefault = false
            }
          ] : [],
          var.enable_tempo ? [
            {
              name   = "Tempo"
              uid    = "tempo"
              type   = "tempo"
              access = "proxy"
              url    = "http://tempo.${var.namespace}.svc.cluster.local:3200"
              jsonData = {
                tracesToLogsV2 = {
                  datasourceUid = "loki"
                }
                serviceMap = {
                  datasourceUid = "prometheus"
                }
              }
            }
          ] : []
        )
      }
      alertmanager = {
        enabled = false
      }
      prometheus = {
        prometheusSpec = {
          retention = "12h"
          storageSpec = var.enable_prometheus_persistence ? {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.monitoring_storage_class_name
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.prometheus_storage_size
                  }
                }
              }
            }
          } : null
        }
      }
    })
  ]
}

resource "helm_release" "loki" {
  count            = var.enabled && var.enable_loki ? 1 : 0
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = kubernetes_namespace_v1.this[0].metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      deploymentMode = "SingleBinary"
      loki = {
        auth_enabled = false
        commonConfig = {
          path_prefix        = "/tmp/loki"
          replication_factor = 1
        }
        storage = {
          type = "s3"
          bucketNames = {
            chunks = var.loki_storage.bucket_name
            ruler  = var.loki_storage.bucket_name
            admin  = var.loki_storage.bucket_name
          }
          s3 = {
            endpoint          = var.loki_storage.endpoint
            region            = var.loki_storage.region
            accessKeyId       = var.loki_storage.access_key_id
            secretAccessKey   = var.loki_storage.secret_access_key
            s3ForcePathStyle  = true
            signatureVersion  = "v4"
            insecure          = false
            disable_dualstack = true
          }
        }
        schemaConfig = {
          configs = [
            {
              from         = "2024-04-01"
              store        = "tsdb"
              object_store = "s3"
              schema       = "v13"
              index = {
                prefix = "loki_index_"
                period = "24h"
              }
            }
          ]
        }
        limits_config = {
          retention_period = var.loki_retention_period
        }
        compactor = {
          working_directory    = "/tmp/loki/compactor"
          retention_enabled    = true
          delete_request_store = "s3"
        }
        rulerConfig = {
          wal = {
            dir = "/tmp/loki/ruler-wal"
          }
        }
        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/tmp/loki/tsdb-index"
            cache_location         = "/tmp/loki/tsdb-cache"
          }
          bloom_shipper = {
            working_directory = "/tmp/loki/bloomshipper"
          }
        }
      }
      singleBinary = {
        replicas = 1
        persistence = {
          enabled = false
        }
      }
      read = {
        replicas = 0
      }
      write = {
        replicas = 0
      }
      backend = {
        replicas = 0
      }
      chunksCache = {
        enabled = false
      }
      resultsCache = {
        enabled = false
      }
      test = {
        enabled = false
      }
      lokiCanary = {
        enabled = false
      }
    })
  ]
}

resource "helm_release" "tempo" {
  count            = var.enabled && var.enable_tempo ? 1 : 0
  name             = "tempo"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "tempo"
  namespace        = kubernetes_namespace_v1.this[0].metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      replicas = 1
      tempo = {
        retention = var.tempo_retention_period
        metricsGenerator = {
          enabled = false
        }
        storage = {
          trace = {
            backend = "s3"
            wal = {
              path = "/tmp/tempo/wal"
            }
            s3 = {
              bucket         = var.tempo_storage.bucket_name
              endpoint       = replace(var.tempo_storage.endpoint, "https://", "")
              region         = var.tempo_storage.region
              access_key     = var.tempo_storage.access_key_id
              secret_key     = var.tempo_storage.secret_access_key
              forcepathstyle = true
              insecure       = false
            }
          }
        }
      }
      persistence = {
        enabled = false
      }
      tempoQuery = {
        enabled = false
      }
      serviceMonitor = {
        enabled = false
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
      jaeger = {
        image = {
          registry = "docker.io"
        }
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
        strategy = var.kiali_auth_strategy
      }
      external_services = {
        prometheus = {
          url = "http://monitoring-kube-prometheus-prometheus.${var.namespace}.svc:9090"
        }
        grafana = {
          enabled      = var.enable_prometheus_stack
          internal_url = "http://monitoring-grafana.${var.namespace}.svc"
          external_url = "https://${var.hosts.grafana}"
        }
        tracing = {
          enabled      = var.enable_tempo || var.enable_jaeger
          internal_url = var.enable_tempo ? "http://tempo.${var.namespace}.svc.cluster.local:3200" : "http://jaeger.${var.namespace}.svc:16686"
          external_url = "https://${local.tracing_host}"
          provider     = var.enable_tempo ? "tempo" : "jaeger"
          use_grpc     = false
          tempo_config = var.enable_tempo ? {
            datasource_uid = "tempo"
            org_id         = "1"
            url_format     = "grafana"
          } : null
        }
      }
    })
  ]
}

resource "null_resource" "token_policy" {
  count = var.enabled ? 1 : 0

  triggers = {
    manifest_sha = nonsensitive(sha1(local.token_policy_manifest))
  }

  provisioner "local-exec" {
    command = "${var.kubectl_path} --kubeconfig=${local.kubeconfig_path} apply -f - <<'YAML'\n${local.token_policy_manifest}\nYAML"
  }

  depends_on = [helm_release.kiali]
}

resource "null_resource" "kiali_route" {
  count = var.enabled && var.enable_kiali ? 1 : 0

  triggers = {
    manifest_sha = sha1(local.kiali_route_manifest)
  }

  provisioner "local-exec" {
    command = "${var.kubectl_path} --kubeconfig=${local.kubeconfig_path} apply -f - <<'YAML'\n${local.kiali_route_manifest}\nYAML"
  }

  depends_on = [helm_release.kiali]
}

resource "null_resource" "grafana_route" {
  count = var.enabled && var.enable_prometheus_stack ? 1 : 0

  triggers = {
    manifest_sha = sha1(local.grafana_route_manifest)
  }

  provisioner "local-exec" {
    command = "${var.kubectl_path} --kubeconfig=${local.kubeconfig_path} apply -f - <<'YAML'\n${local.grafana_route_manifest}\nYAML"
  }

  depends_on = [helm_release.prometheus_stack]
}

resource "null_resource" "tracing_route" {
  count = var.enabled && (var.enable_tempo || var.enable_jaeger) ? 1 : 0

  triggers = {
    manifest_sha = sha1(local.tracing_route_manifest)
  }

  provisioner "local-exec" {
    command = "${var.kubectl_path} --kubeconfig=${local.kubeconfig_path} apply -f - <<'YAML'\n${local.tracing_route_manifest}\nYAML"
  }

  depends_on = [helm_release.tempo, helm_release.jaeger]
}

resource "null_resource" "legacy_jaeger_route_cleanup" {
  count = var.enabled ? 1 : 0

  triggers = {
    namespace = var.namespace
  }

  provisioner "local-exec" {
    command = "${var.kubectl_path} --kubeconfig=${local.kubeconfig_path} delete httproute jaeger -n ${var.namespace} --ignore-not-found"
  }

  depends_on = [null_resource.tracing_route]
}

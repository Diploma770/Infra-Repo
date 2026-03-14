terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}

resource "random_password" "grafana_admin" {
  length  = 24
  special = true
}

resource "kubernetes_namespace" "observability" {
  metadata {
    name = var.namespace
  }
}

resource "google_service_account" "loki" {
  project      = var.project_id
  account_id   = "loki-sa"
  display_name = "Loki storage service account"
}

resource "google_service_account" "tempo" {
  project      = var.project_id
  account_id   = "tempo-sa"
  display_name = "Tempo storage service account"
}

resource "kubernetes_service_account" "loki" {
  metadata {
    name      = "loki"
    namespace = kubernetes_namespace.observability.metadata[0].name

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.loki.email
    }
  }
}

resource "kubernetes_service_account" "tempo" {
  metadata {
    name      = "tempo"
    namespace = kubernetes_namespace.observability.metadata[0].name

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.tempo.email
    }
  }
}

resource "google_service_account_iam_member" "loki_workload_identity" {
  service_account_id = google_service_account.loki.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${kubernetes_service_account.loki.metadata[0].name}]"
}

resource "google_service_account_iam_member" "tempo_workload_identity" {
  service_account_id = google_service_account.tempo.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${kubernetes_service_account.tempo.metadata[0].name}]"
}

resource "google_storage_bucket_iam_member" "loki_bucket_access" {
  bucket = var.loki_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.loki.email}"
}

resource "google_storage_bucket_iam_member" "tempo_bucket_access" {
  bucket = var.tempo_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.tempo.email}"
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "obs"
  namespace  = kubernetes_namespace.observability.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "82.10.3"

  values = [yamlencode({
    prometheusOperator = {
      admissionWebhooks = {
        enabled = false
      }
    }
    grafana = {
      enabled       = true
      adminUser     = "admin"
      adminPassword = random_password.grafana_admin.result
      service = {
        type = var.grafana_service_type
      }
      persistence = {
        enabled = true
        size    = "10Gi"
      }
      additionalDataSources = [
        {
          name   = "Loki"
          uid    = "loki"
          type   = "loki"
          access = "proxy"
          url    = "http://loki-gateway.${var.namespace}.svc.cluster.local"
        },
        {
          name   = "Tempo"
          uid    = "tempo"
          type   = "tempo"
          access = "proxy"
          url    = "http://tempo.${var.namespace}.svc.cluster.local:3100"
        }
      ]
    }
    prometheus = {
      prometheusSpec = {
        retention = "7d"
        storageSpec = {
          volumeClaimTemplate = {
            spec = {
              accessModes = ["ReadWriteOnce"]
              resources = {
                requests = {
                  storage = "30Gi"
                }
              }
            }
          }
        }
        podMonitorSelectorNilUsesHelmValues     = false
        serviceMonitorSelectorNilUsesHelmValues = false
      }
    }
    alertmanager = {
      enabled = false
    }
  })]

  depends_on = [kubernetes_namespace.observability]
}

resource "helm_release" "loki" {
  name       = "loki"
  namespace  = kubernetes_namespace.observability.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.55.0"

  values = [yamlencode({
    deploymentMode = "SingleBinary"
    loki = {
      auth_enabled = false
      commonConfig = {
        replication_factor = 1
      }
      schemaConfig = {
        configs = [
          {
            from         = "2024-01-01"
            store        = "tsdb"
            object_store = "gcs"
            schema       = "v13"
            index = {
              prefix = "loki_index_"
              period = "24h"
            }
          }
        ]
      }
      storage = {
        type = "gcs"
        bucketNames = {
          chunks = var.loki_bucket_name
          ruler  = var.loki_bucket_name
          admin  = var.loki_bucket_name
        }
      }
      storage_config = {
        gcs = {
          bucket_name = var.loki_bucket_name
        }
      }
    }
    serviceAccount = {
      create = false
      name   = kubernetes_service_account.loki.metadata[0].name
    }
    singleBinary = {
      replicas = 1
      persistence = {
        enabled = true
        size    = "20Gi"
      }
    }
    backend = {
      replicas = 0
    }
    read = {
      replicas = 0
    }
    write = {
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
    monitoring = {
      serviceMonitor = {
        enabled = true
      }
    }
  })]

  depends_on = [
    google_storage_bucket_iam_member.loki_bucket_access,
    google_service_account_iam_member.loki_workload_identity
  ]
}

resource "helm_release" "tempo" {
  name       = "tempo"
  namespace  = kubernetes_namespace.observability.metadata[0].name
  repository = "https://grafana-community.github.io/helm-charts"
  chart      = "tempo"
  version    = "1.26.7"

  values = [yamlencode({
    tempo = {
      storage = {
        trace = {
          backend = "gcs"
          gcs = {
            bucket_name = var.tempo_bucket_name
          }
        }
      }
    }
    serviceAccount = {
      create = false
      name   = kubernetes_service_account.tempo.metadata[0].name
    }
    persistence = {
      enabled = true
      size    = "10Gi"
    }
    serviceMonitor = {
      enabled = true
    }
  })]

  depends_on = [
    google_storage_bucket_iam_member.tempo_bucket_access,
    google_service_account_iam_member.tempo_workload_identity
  ]
}

resource "helm_release" "alloy" {
  name       = "alloy"
  namespace  = kubernetes_namespace.observability.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = "1.6.2"

  values = [yamlencode({
    controller = {
      type = "daemonset"
    }
    serviceAccount = {
      create = true
    }
    rbac = {
      create = true
    }
    service = {
      enabled = true
      type    = "ClusterIP"
    }
    alloy = {
      extraPorts = [
        {
          name        = "otlp-grpc"
          port        = 4317
          targetPort  = 4317
          protocol    = "TCP"
          appProtocol = "h2c"
        },
        {
          name       = "otlp-http"
          port       = 4318
          targetPort = 4318
          protocol   = "TCP"
        }
      ]
      configMap = {
        content = <<-EOT
          logging {
            level = "info"
            format = "logfmt"
          }

          discovery.kubernetes "pods" {
            role = "pod"
          }

          discovery.relabel "pod_logs" {
            targets = discovery.kubernetes.pods.targets

            rule {
              source_labels = ["__meta_kubernetes_namespace"]
              target_label  = "namespace"
            }

            rule {
              source_labels = ["__meta_kubernetes_pod_name"]
              target_label  = "pod"
            }

            rule {
              source_labels = ["__meta_kubernetes_pod_container_name"]
              target_label  = "container"
            }

            rule {
              source_labels = ["__meta_kubernetes_pod_label_app_kubernetes_io_name", "__meta_kubernetes_pod_label_app"]
              separator     = ";"
              regex         = "(.+);.*|;(.+)"
              replacement   = "$1$2"
              target_label  = "app"
            }
          }

          loki.write "default" {
            endpoint {
              url = "http://loki-gateway.${var.namespace}.svc.cluster.local/loki/api/v1/push"
            }

            external_labels = {
              cluster = "${var.cluster_name}"
            }
          }

          loki.source.kubernetes "pods" {
            targets    = discovery.relabel.pod_logs.output
            forward_to = [loki.write.default.receiver]
          }

          otelcol.receiver.otlp "default" {
            grpc {
              endpoint = "0.0.0.0:4317"
            }

            http {
              endpoint = "0.0.0.0:4318"
            }

            output {
              traces = [otelcol.processor.batch.default.input]
            }
          }

          otelcol.processor.batch "default" {
            output {
              traces = [otelcol.exporter.otlp.tempo.input]
            }
          }

          otelcol.exporter.otlp "tempo" {
            client {
              endpoint = "tempo.${var.namespace}.svc.cluster.local:4317"

              tls {
                insecure             = true
                insecure_skip_verify = true
              }
            }
          }
        EOT
      }
    }
    serviceMonitor = {
      enabled = true
    }
  })]

  depends_on = [helm_release.loki, helm_release.tempo, helm_release.kube_prometheus_stack]
}
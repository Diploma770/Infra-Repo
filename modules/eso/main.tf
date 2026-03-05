terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# 1) GCP Service Account for ESO
resource "google_service_account" "eso_gsa" {
  project      = var.project_id
  account_id   = var.gcp_service_account_id
  display_name = "External Secrets Operator"
}

# 2) Grant Secret Manager access (project-wide; you can tighten later)
resource "google_project_iam_member" "eso_secret_access" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.eso_gsa.email}"
}

# 3) Namespace
resource "kubernetes_namespace" "eso" {
  metadata { name = var.namespace }
}

# 4) (Optional) Create the Kubernetes ServiceAccount and annotate it
resource "kubernetes_service_account" "eso_ksa" {
  count = var.create_k8s_service_account ? 1 : 0

  metadata {
    name      = var.k8s_service_account_name
    namespace = kubernetes_namespace.eso.metadata[0].name

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.eso_gsa.email
    }
  }
}

# If you don't create KSA, we still need its full name
locals {
  eso_ksa_name      = var.k8s_service_account_name
  eso_ksa_namespace = var.namespace
}

# 5) Allow KSA to impersonate the GSA (Workload Identity)
resource "google_service_account_iam_member" "eso_wi_user" {
  service_account_id = google_service_account.eso_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${local.eso_ksa_namespace}/${local.eso_ksa_name}]"
}

# 6) Install ESO via Helm, using the existing KSA
resource "helm_release" "eso" {
  name            = "external-secrets"
  namespace       = kubernetes_namespace.eso.metadata[0].name
  repository      = "https://charts.external-secrets.io"
  chart           = "external-secrets"
  version         = "2.0.1" # pin explicitly
  timeout         = 900
  wait            = true
  atomic          = true
  cleanup_on_fail = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = local.eso_ksa_name
  }

  depends_on = [
    kubernetes_namespace.eso,
    google_service_account_iam_member.eso_wi_user,
    google_project_iam_member.eso_secret_access
  ]
}

resource "null_resource" "wait_eso_crds" {
  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      for i in $(seq 1 ${var.crd_ready_wait_retries}); do
        ok=1
        kubectl get crd externalsecrets.external-secrets.io >/dev/null 2>&1 || ok=0
        kubectl get crd clustersecretstores.external-secrets.io >/dev/null 2>&1 || ok=0
        if [ "$ok" -eq 1 ]; then
          exit 0
        fi
        if [ "$i" -eq "${var.crd_ready_wait_retries}" ]; then
          echo "Required ESO CRDs not ready"
          exit 1
        fi
        sleep ${var.crd_ready_wait_seconds}
      done
    EOT
  }

  depends_on = [helm_release.eso]
}

resource "null_resource" "gcp_sm_store" {
  count = var.create_cluster_secret_store ? 1 : 0

  triggers = {
    store_name = var.cluster_secret_store_name
    project_id = var.project_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      for i in $(seq 1 ${var.crd_ready_wait_retries}); do
        if kubectl get crd clustersecretstores.external-secrets.io >/dev/null 2>&1; then
          break
        fi
        if [ "$i" -eq "${var.crd_ready_wait_retries}" ]; then
          echo "ClusterSecretStore CRD not ready after ${var.crd_ready_wait_retries} attempts"
          exit 1
        fi
        sleep ${var.crd_ready_wait_seconds}
      done

      cat <<'EOF' | kubectl apply -f -
      apiVersion: external-secrets.io/v1
      kind: ClusterSecretStore
      metadata:
        name: ${var.cluster_secret_store_name}
      spec:
        provider:
          gcpsm:
            projectID: ${var.project_id}
      EOF
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete clustersecretstore ${self.triggers.store_name} --ignore-not-found=true"
  }

  depends_on = [null_resource.wait_eso_crds]
}

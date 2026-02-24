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
  name       = "external-secrets"
  namespace  = kubernetes_namespace.eso.metadata[0].name
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

  # IMPORTANT: reuse KSA (don't let Helm create it)
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

resource "kubernetes_manifest" "gcp_sm_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = var.cluster_secret_store_name
    }
    spec = {
      provider = {
        gcpsm = {
          projectID = var.project_id
        }
      }
    }
  }

  depends_on = [helm_release.eso]
}

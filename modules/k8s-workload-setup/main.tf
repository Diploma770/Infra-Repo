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

# Kubernetes namespaces for workloads
# resource "kubernetes_namespace" "workload_namespaces" {
#   for_each = toset(var.namespaces)

#   metadata {
#     name = each.value
#   }
# }

# Kubernetes service accounts for Cloud SQL workload identity
resource "kubernetes_service_account" "cloudsql_ksa" {
  for_each = toset(var.namespaces)

  metadata {
    name      = var.cloudsql_ksa_name
    namespace = each.value

    annotations = {
      "iam.gke.io/gcp-service-account" = var.cloudsql_sa_email
    }
  }

  # depends_on = [kubernetes_namespace.workload_namespaces]
}

# Workload Identity binding for Cloud SQL access from GKE
resource "google_service_account_iam_member" "workload_identity" {
  for_each = toset(var.namespaces)

  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.cloudsql_sa_email}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value}/${var.cloudsql_ksa_name}]"

  depends_on = [kubernetes_service_account.cloudsql_ksa]
}

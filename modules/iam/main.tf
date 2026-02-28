resource "google_service_account" "terraform" {
  project      = var.project_id
  account_id   = var.terraform_sa_name
  display_name = "Terraform Deployer"
}

resource "google_service_account" "cicd" {
  project      = var.project_id
  account_id   = var.cicd_sa_name
  display_name = "CI/CD Deployer"
}

# Terraform SA permissions (minimal for infra + state bucket)
resource "google_project_iam_member" "terraform_roles" {
  for_each = toset([
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/container.admin",
    "roles/cloudsql.admin",
    "roles/pubsub.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# resource "google_service_account_iam_member" "terraform_wif_user" {
#   count = var.terraform_github_principal == null ? 0 : 1

#   service_account_id = google_service_account.terraform.name
#   role               = "roles/iam.workloadIdentityUser"
#   member             = var.terraform_github_principal
# }

# resource "google_service_account_iam_member" "terraform_token_creator" {
#   count = var.terraform_github_principal == null ? 0 : 1

#   service_account_id = google_service_account.terraform.name
#   role               = "roles/iam.serviceAccountTokenCreator"
#   member             = var.terraform_github_principal
# }

# CI/CD permissions (push images + deploy to GKE)
resource "google_project_iam_member" "cicd_roles" {
  for_each = toset([
    "roles/artifactregistry.writer",
    "roles/container.developer",
    "roles/iam.workloadIdentityUser"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cicd.email}"
}

resource "google_service_account_iam_member" "cicd_wif_user" {
  count = var.cicd_github_principal == null ? 0 : 1

  service_account_id = google_service_account.cicd.name
  role               = "roles/iam.workloadIdentityUser"
  member             = var.cicd_github_principal
}

resource "google_service_account_iam_member" "cicd_token_creator" {
  count = var.cicd_github_principal == null ? 0 : 1

  service_account_id = google_service_account.cicd.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = var.cicd_github_principal
}

# Cloud SQL service account for GKE workloads
resource "google_service_account" "cloudsql_sa" {
  project      = var.project_id
  account_id   = "gke-cloudsql-sa"
  display_name = "GKE Cloud SQL Auth Proxy SA"
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql_sa.email}"
}

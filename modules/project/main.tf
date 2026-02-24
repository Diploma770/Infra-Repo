resource "google_project" "project-dev" {
  name            = var.name
  project_id      = var.project_id
  billing_account = var.billing_account_id

  org_id    = var.org_id
#   folder_id = var.folder_id

#   labels = var.labels
}

module "apis" {
  source     = "../project-apis"
  project_id = google_project.project-dev.project_id
  apis       = var.apis
}

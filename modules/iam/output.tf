output "terraform_sa_email" {
  description = "Terraform service account email"
  value       = google_service_account.terraform.email
}

output "cicd_sa_email" {
  description = "CI/CD service account email"
  value       = google_service_account.cicd.email
}

output "cloudsql_sa_email" {
  description = "Cloud SQL service account email"
  value       = google_service_account.cloudsql_sa.email
}

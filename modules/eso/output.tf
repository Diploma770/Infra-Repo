output "gcp_service_account_email" {
  value = google_service_account.eso_gsa.email
}

output "namespace" {
  value = var.namespace
}

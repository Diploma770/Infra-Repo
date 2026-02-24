output "function_name" {
  value = google_cloudfunctions2_function.notify.name
}

output "function_sa_email" {
  value = google_service_account.fn_sa.email
}

output "repository_id" {
  description = "The ID of the Artifact Registry repository"
  value       = google_artifact_registry_repository.repository.id
}

output "repository_name" {
  description = "The name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.repository.name
}

output "repository_location" {
  description = "The location of the Artifact Registry repository"
  value       = google_artifact_registry_repository.repository.location
}

output "repository_full_name" {
  description = "The full resource name of the repository"
  value       = google_artifact_registry_repository.repository.name
}

output "repository_url" {
  description = "The Docker repository URL"
  value       = "${google_artifact_registry_repository.repository.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repository.repository_id}"
}

output "create_time" {
  description = "The time when the repository was created"
  value       = google_artifact_registry_repository.repository.create_time
}

output "update_time" {
  description = "The time when the repository was last updated"
  value       = google_artifact_registry_repository.repository.update_time
}

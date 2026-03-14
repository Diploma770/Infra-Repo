output "ingress_static_ip_name" {
  description = "Global static IP name to use in Ingress annotation kubernetes.io/ingress.global-static-ip-name"
  value       = module.ingress_ip.name
}

output "ingress_static_ip_address" {
  description = "Reserved global static IP address for GKE Ingress"
  value       = module.ingress_ip.address
}

output "artifact_registry_repository_url" {
  description = "Artifact Registry Docker repository URL"
  value       = module.artifact_registry.repository_url
}

output "observability_loki_bucket_name" {
  description = "GCS bucket used by Loki for log storage"
  value       = "${var.project_id}-loki-${var.environment}"
}

output "observability_tempo_bucket_name" {
  description = "GCS bucket used by Tempo for trace storage"
  value       = "${var.project_id}-tempo-${var.environment}"
}

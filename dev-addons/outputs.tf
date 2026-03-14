output "grafana_admin_password" {
  description = "Generated Grafana admin password"
  value       = module.observability.grafana_admin_password
  sensitive   = true
}

output "grafana_service_name" {
  description = "Helm release name for the Grafana and Prometheus stack"
  value       = module.observability.grafana_service_name
}

output "observability_namespace" {
  description = "Namespace that hosts the observability stack"
  value       = module.observability.namespace
}
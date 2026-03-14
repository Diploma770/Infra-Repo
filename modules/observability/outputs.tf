output "grafana_admin_password" {
  description = "Generated admin password for Grafana"
  value       = random_password.grafana_admin.result
  sensitive   = true
}

output "grafana_service_name" {
  description = "Helm release name for the Grafana and Prometheus stack"
  value       = helm_release.kube_prometheus_stack.name
}

output "namespace" {
  description = "Observability namespace"
  value       = kubernetes_namespace.observability.metadata[0].name
}
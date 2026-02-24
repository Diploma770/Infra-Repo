# output "namespace_names" {
#   description = "List of created Kubernetes namespace names"
#   value       = [for ns in kubernetes_namespace.workload_namespaces : ns.metadata[0].name]
# }

output "cloudsql_ksa_names" {
  description = "Map of namespace to Cloud SQL Kubernetes service account names"
  value       = { for k, sa in kubernetes_service_account.cloudsql_ksa : k => sa.metadata[0].name }
}

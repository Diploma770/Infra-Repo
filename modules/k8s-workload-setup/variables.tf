variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "namespaces" {
  type        = list(string)
  description = "List of Kubernetes namespaces to create"
  default     = ["default"]
}

variable "cloudsql_namespaces" {
  type        = list(string)
  description = "List of namespaces that need Cloud SQL access via workload identity"
  default     = []
}

variable "cloudsql_sa_email" {
  type        = string
  description = "GCP service account email for Cloud SQL access"
}

variable "cloudsql_ksa_name" {
  type        = string
  description = "Kubernetes service account name for Cloud SQL"
  default     = "cloudsql-ksa"
}

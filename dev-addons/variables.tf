variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_location" {
  type        = string
  description = "GKE cluster location (zone for zonal cluster)"
}

variable "cloudsql_sa_email" {
  type        = string
  description = "GCP service account email used by workloads for Cloud SQL access"
}

variable "workload_namespaces" {
  type    = list(string)
  default = ["default"]
}

variable "cloudsql_ksa_name" {
  type    = string
  default = "cloudsql-ksa"
}

variable "eso_namespace" {
  type    = string
  default = "external-secrets"
}

variable "eso_k8s_service_account_name" {
  type    = string
  default = "external-secrets"
}

variable "eso_create_k8s_service_account" {
  type    = bool
  default = true
}

variable "eso_gcp_service_account_id" {
  type    = string
  default = "external-secrets"
}

variable "argocd_create_repo_secret" {
  type    = bool
  default = false
}

variable "argocd_repo_secret_name" {
  type    = string
  default = "repo-main"
}

variable "argocd_repo_url" {
  type    = string
  default = null
}

variable "argocd_repo_auth_type" {
  type    = string
  default = "ssh"
}

variable "argocd_repo_ssh_private_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "argocd_repo_username" {
  type    = string
  default = null
}

variable "argocd_repo_password" {
  type      = string
  default   = null
  sensitive = true
}

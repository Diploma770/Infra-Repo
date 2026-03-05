variable "project_id" { type = string }

variable "namespace" {
  type    = string
  default = "external-secrets"
}

# Reuse existing KSA name (set it to your existing one)
variable "k8s_service_account_name" {
  type    = string
  default = "external-secrets"
}

# Create it or reuse it
variable "create_k8s_service_account" {
  type    = bool
  default = true
}

# GCP SA name (account_id without domain)
variable "gcp_service_account_id" {
  type    = string
  default = "external-secrets"
}

variable "cluster_secret_store_name" {
  type    = string
  default = "gcp-sm-store"
}

variable "create_cluster_secret_store" {
  type    = bool
  default = true
}

variable "crd_ready_wait_seconds" {
  type    = number
  default = 20
}

variable "crd_ready_wait_retries" {
  type    = number
  default = 15
}

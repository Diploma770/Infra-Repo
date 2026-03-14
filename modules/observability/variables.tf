variable "project_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "observability"
}

variable "loki_bucket_name" {
  type = string
}

variable "tempo_bucket_name" {
  type = string
}

variable "grafana_service_type" {
  type    = string
  default = "LoadBalancer"
}
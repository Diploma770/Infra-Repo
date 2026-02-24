variable "project_id" { type = string }
variable "cluster_name" { type = string }

variable "cluster_zone" {
  type        = string
  description = "Control plane zone (zonal cluster), e.g. europe-west3-a"
}

variable "node_zones" {
  type        = list(string)
  description = "Zones for nodes, e.g. [europe-west3-a, europe-west3-b]"
}

variable "network_name" { type = string }
variable "subnet_name" { type = string }

variable "pods_range_name" { type = string }
variable "services_range_name" { type = string }

variable "master_ipv4_cidr_block" {
  type        = string
  description = "Private master CIDR, e.g. 172.16.0.0/28"
}

variable "machine_type" {
  type    = string
  default = "e2-highcpu-4"
}

variable "gke_events_topic_id" {
  type        = string
  description = "Pub/Sub topic ID for GKE notifications"
}

variable "authorized_networks_cidr" {
  type        = string
  description = "CIDR block allowed to access GKE master API (e.g. your VPC subnet)"
}

variable "cloudsql_sa_email" {
  type        = string
  description = "Cloud SQL service account email for workload identity"
}


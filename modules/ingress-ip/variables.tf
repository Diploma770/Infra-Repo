variable "project_id" { type = string }

variable "name" {
  type        = string
  description = "Static global IP name used by GKE Ingress annotation."
}

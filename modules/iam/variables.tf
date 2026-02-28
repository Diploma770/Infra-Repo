variable "project_id" {
  type = string
}

variable "terraform_sa_name" {
  type    = string
  default = "terraform-sa"
}

variable "cicd_sa_name" {
  type    = string
  default = "cicd-sa"
}

variable "terraform_github_principal" {
  type        = string
  description = "GitHub OIDC principal (principal or principalSet) allowed to impersonate Terraform SA"
  default     = null
}

variable "cicd_github_principal" {
  type        = string
  description = "GitHub OIDC principal (principal or principalSet) allowed to impersonate CI/CD SA"
  default     = null
}

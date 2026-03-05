variable "project_id" {
  type    = string
  default = "my-dev-770"
}

variable "region" {
  type    = string
  default = "europe-west3"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "billing_account_id" {
  type = string
}

variable "org_id" {
  type    = string
  default = "0"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "notify_to_email" {
  type    = string
  default = "you@example.com"
}
variable "notify_from_email" {
  type    = string
  default = "you@example.com"
}

variable "smtp_user" {
  type    = string
  default = "you@example.com"
}
variable "smtp_app_password" {
  type      = string
  sensitive = true
}

variable "functions_source_bucket" {
  type    = string
  default = "my-dev-bucket-770"
}

variable "functions_source_object" {
  type    = string
  default = "notify.zip"
}

variable "terraform_github_principal" {
  type        = string
  description = "GitHub OIDC principalSet/principal allowed to impersonate terraform-sa"
  default     = null
}

variable "cicd_github_principal" {
  type        = string
  description = "GitHub OIDC principalSet/principal allowed to impersonate cicd-sa"
  default     = null
}

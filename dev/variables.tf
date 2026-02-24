variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "billing_account_id" {
  type = string
}

variable "org_id" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "notify_to_email"   { type = string }
variable "notify_from_email" { type = string }

variable "smtp_user" { type = string }
variable "smtp_app_password" {
  type      = string
  sensitive = true
}

variable "functions_source_bucket" { type = string }
variable "functions_source_object" { type = string }

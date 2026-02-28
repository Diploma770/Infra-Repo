variable "project_id" { type = string }
variable "region" { type = string }

variable "function_name" { type = string }

variable "topic_id" {
  type        = string
  description = "Pub/Sub topic ID that triggers the function."
}

variable "to_email" { type = string }
variable "from_email" { type = string }

# Gmail SMTP
variable "smtp_user" {
  type        = string
  description = "Gmail address used to send email."
}

variable "smtp_app_password" {
  type        = string
  sensitive   = true
  description = "Gmail App Password (recommended) for SMTP auth."
}

# Function source code archive in GCS
variable "source_bucket" { type = string }
variable "source_object" { type = string }

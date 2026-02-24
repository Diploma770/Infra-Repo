variable "project_id" { type = string }
variable "region"     { type = string }

variable "instance_name" { type = string }

variable "db_name" {
  type    = string
  default = "app"
}

variable "db_user" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "tier" {
  type    = string
  default = "db-f1-micro"
}

variable "disk_size_gb" {
  type    = number
  default = 10
}

variable "authorized_networks" {
  type        = list(string)
  description = "CIDR ranges allowed to connect to Cloud SQL public IP."
  default     = []
}
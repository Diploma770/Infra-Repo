variable "name" { type = string }
variable "project_id" { type = string }

variable "billing_account_id" { type = string }

variable "org_id" {
  type    = string
  default = null
}

variable "folder_id" {
  type    = string
  default = null
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "apis" {
  type    = list(string)
  default = []
}

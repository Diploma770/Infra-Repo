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

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "create_repo_secret" {
  type    = bool
  default = false
}

variable "repo_secret_name" {
  type    = string
  default = "repo-main"
}

variable "repo_url" {
  type    = string
  default = null
}

variable "repo_auth_type" {
  type    = string
  default = "ssh"

  validation {
    condition     = contains(["ssh", "https"], var.repo_auth_type)
    error_message = "repo_auth_type must be either 'ssh' or 'https'."
  }
}

variable "repo_ssh_private_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "repo_username" {
  type    = string
  default = null
}

variable "repo_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "project_id" {
  description = "The project ID to deploy the Artifact Registry repository"
  type        = string
}

variable "location" {
  description = "The location of the Artifact Registry repository"
  type        = string
}

variable "repository_id" {
  description = "The ID of the Artifact Registry repository"
  type        = string
}

variable "description" {
  description = "Description of the Artifact Registry repository"
  type        = string
  default     = "Artifact Registry repository"
}

variable "labels" {
  description = "Labels to apply to the repository"
  type        = map(string)
  default     = {}
}

variable "immutable_tags" {
  description = "Whether tags are immutable"
  type        = bool
  default     = false
}

variable "cleanup_policy_dry_run" {
  description = "If true, the cleanup pipeline is prevented from deleting versions in this repository"
  type        = bool
  default     = false
}

variable "cleanup_policies" {
  description = "Cleanup policies for the repository"
  type = list(object({
    id     = string
    action = string
    condition = optional(object({
      tag_state             = optional(string)
      tag_prefixes          = optional(list(string))
      version_name_prefixes = optional(list(string))
      package_name_prefixes = optional(list(string))
      older_than            = optional(string)
      newer_than            = optional(string)
    }))
    most_recent_versions = optional(object({
      package_name_prefixes = optional(list(string))
      keep_count            = optional(number)
    }))
  }))
  default = []
}

variable "iam_members" {
  description = "IAM members and their roles for the repository"
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}

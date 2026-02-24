variable "project_id" {
  type        = string
  description = "GCP project ID where APIs will be enabled."
}

variable "apis" {
  type        = list(string)
  description = "List of GCP service APIs to enable (e.g. compute.googleapis.com)."
}

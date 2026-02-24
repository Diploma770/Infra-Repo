variable "project_id" {
  type = string
}

variable "buckets" {
  type = map(object({
    location   = string
    versioning = bool
  }))
}

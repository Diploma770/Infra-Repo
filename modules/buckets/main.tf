resource "google_storage_bucket" "buckets" {
  for_each = var.buckets

  name     = each.key
  project  = var.project_id
  location = each.value.location

  uniform_bucket_level_access = true

  versioning {
    enabled = each.value.versioning
  }
}

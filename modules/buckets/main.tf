locals {
  protected_buckets = {
    for name, cfg in var.buckets : name => cfg
    if cfg.prevent_destroy
  }

  normal_buckets = {
    for name, cfg in var.buckets : name => cfg
    if !cfg.prevent_destroy
  }
}

resource "google_storage_bucket" "buckets" {
  for_each = local.normal_buckets

  name     = each.key
  project  = var.project_id
  location = each.value.location

  uniform_bucket_level_access = true

  versioning {
    enabled = each.value.versioning
  }
}

resource "google_storage_bucket" "protected_buckets" {
  for_each = local.protected_buckets

  name     = each.key
  project  = var.project_id
  location = each.value.location

  uniform_bucket_level_access = true

  versioning {
    enabled = each.value.versioning
  }

  lifecycle {
    prevent_destroy = true
  }
}

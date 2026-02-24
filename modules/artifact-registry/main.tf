resource "google_artifact_registry_repository" "repository" {
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = "DOCKER"

  labels = var.labels

  dynamic "docker_config" {
    for_each = var.immutable_tags ? [1] : []
    content {
      immutable_tags = var.immutable_tags
    }
  }

  cleanup_policy_dry_run = var.cleanup_policy_dry_run

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action

      dynamic "condition" {
        for_each = lookup(cleanup_policies.value, "condition", null) != null ? [cleanup_policies.value.condition] : []
        content {
          tag_state             = lookup(condition.value, "tag_state", null)
          tag_prefixes          = lookup(condition.value, "tag_prefixes", null)
          version_name_prefixes = lookup(condition.value, "version_name_prefixes", null)
          package_name_prefixes = lookup(condition.value, "package_name_prefixes", null)
          older_than            = lookup(condition.value, "older_than", null)
          newer_than            = lookup(condition.value, "newer_than", null)
        }
      }

      dynamic "most_recent_versions" {
        for_each = lookup(cleanup_policies.value, "most_recent_versions", null) != null ? [cleanup_policies.value.most_recent_versions] : []
        content {
          package_name_prefixes = lookup(most_recent_versions.value, "package_name_prefixes", null)
          keep_count            = lookup(most_recent_versions.value, "keep_count", null)
        }
      }
    }
  }
}

resource "google_artifact_registry_repository_iam_member" "members" {
  for_each = var.iam_members

  project    = var.project_id
  location   = google_artifact_registry_repository.repository.location
  repository = google_artifact_registry_repository.repository.name
  role       = each.value.role
  member     = each.value.member
}

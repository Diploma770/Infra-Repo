resource "google_service_account" "fn_sa" {
  project      = var.project_id
  account_id   = "${var.function_name}-sa"
  display_name = "Notification Function SA"
}

resource "google_secret_manager_secret" "smtp_password" {
  project   = var.project_id
  secret_id = "${var.function_name}-smtp-pass"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "smtp_password_v1" {
  secret      = google_secret_manager_secret.smtp_password.id
  secret_data = var.smtp_app_password
}

resource "google_secret_manager_secret_iam_member" "fn_secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.smtp_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.fn_sa.email}"
}

resource "google_cloudfunctions2_function" "notify" {
  project  = var.project_id
  location = var.region
  name     = var.function_name

  build_config {
    runtime     = "python311"
    entry_point = "handler"

    source {
      storage_source {
        bucket = var.source_bucket
        object = var.source_object
      }
    }
  }

  service_config {
    service_account_email = google_service_account.fn_sa.email

    environment_variables = {
      TO_EMAIL   = var.to_email
      FROM_EMAIL = var.from_email

      SMTP_HOST = "smtp.gmail.com"
      SMTP_PORT = "587"
      SMTP_USER = var.smtp_user
    }

    secret_environment_variables {
      key        = "SMTP_PASS"
      project_id = var.project_id
      secret     = google_secret_manager_secret.smtp_password.secret_id
      version    = "latest"
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = var.topic_id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}

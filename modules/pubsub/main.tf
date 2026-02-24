resource "google_pubsub_topic" "gke_events" {
  name    = "gke-events"
  project = var.project_id
}

resource "google_pubsub_subscription" "gke_events_sub" {
  name    = "gke-events-sub"
  topic   = google_pubsub_topic.gke_events.name
  project = var.project_id

  ack_deadline_seconds = 20
}

resource "google_pubsub_topic" "monitoring_alerts" {
  name    = "monitoring-alerts"
  project = var.project_id
}

resource "google_pubsub_subscription" "monitoring_alerts_sub" {
  name    = "monitoring-alerts-sub"
  topic   = google_pubsub_topic.monitoring_alerts.name
  project = var.project_id

  ack_deadline_seconds = 20
}

# Commented out - GKE service account is created automatically when GKE cluster is created
# Uncomment this after first apply when GKE exists
# data "google_project" "this" {
#   project_id = var.project_id
# }
# 
# resource "google_pubsub_topic_iam_member" "gke_publisher" {
#   topic  = google_pubsub_topic.gke_events.name
#   role   = "roles/pubsub.publisher"
#   member = "serviceAccount:service-${data.google_project.this.number}@gcp-sa-gke-notifications.iam.gserviceaccount.com"
# }

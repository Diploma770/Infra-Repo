output "gke_events_topic_id" {
  value = google_pubsub_topic.gke_events.id
}

output "monitoring_alerts_topic_id" {
  value = google_pubsub_topic.monitoring_alerts.id
}

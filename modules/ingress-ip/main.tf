resource "google_compute_global_address" "ingress_ip" {
  project = var.project_id
  name    = var.name
}

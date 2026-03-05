resource "google_container_cluster" "this" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.cluster_zone


  network    = var.network_name
  subnetwork = var.subnet_name

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false



  # Private cluster
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block


  }

  # Master authorized networks (who can access k8s API)
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.authorized_networks_cidr
      display_name = "vpc-subnet"
    }
  }

  # VPC-native (required)
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
  }

  networking_mode = "VPC_NATIVE"

  # Send GKE events to Pub/Sub
  notification_config {
    pubsub {
      enabled = true
      topic   = var.gke_events_topic_id
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# 1 node in europe-west3-a
resource "google_container_node_pool" "np_a" {
  name     = "${var.cluster_name}-np-a"
  project  = var.project_id
  location = var.cluster_zone
  cluster  = google_container_cluster.this.name

  node_locations = [var.node_zones[0]]
  node_count     = 1

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    metadata     = { disable-legacy-endpoints = "true" }
  }
}

# 1 node in europe-west3-b
resource "google_container_node_pool" "np_b" {
  name     = "${var.cluster_name}-np-b"
  project  = var.project_id
  location = var.cluster_zone
  cluster  = google_container_cluster.this.name

  node_locations = [var.node_zones[1]]
  node_count     = 1

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    metadata     = { disable-legacy-endpoints = "true" }
  }

  depends_on = [google_container_node_pool.np_a]
}

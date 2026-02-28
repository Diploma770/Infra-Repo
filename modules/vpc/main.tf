resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr

  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.30.0.0/20"
  }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc.name

  direction = "INGRESS"

  source_ranges = [var.subnet_cidr]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  count   = length(var.ssh_source_ranges) > 0 ? 1 : 0
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.vpc.name

  direction     = "INGRESS"
  source_ranges = var.ssh_source_ranges

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# GKE master to nodes communication
resource "google_compute_firewall" "allow_gke_master" {
  count   = var.gke_master_ipv4_cidr != "" ? 1 : 0
  name    = "${var.network_name}-allow-gke-master"
  network = google_compute_network.vpc.name

  direction     = "INGRESS"
  source_ranges = [var.gke_master_ipv4_cidr]

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "8443"]
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_address" "nat_ip" {
  count  = var.enable_nat && var.reserve_nat_ip ? 1 : 0
  name   = "${var.network_name}-nat-ip"
  region = var.region
}

resource "google_compute_router" "router" {
  count   = var.enable_nat ? 1 : 0
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  count  = var.enable_nat ? 1 : 0
  name   = "${var.network_name}-nat"
  router = google_compute_router.router[0].name
  region = var.region

  nat_ip_allocate_option = var.reserve_nat_ip ? "MANUAL_ONLY" : "AUTO_ONLY"
  nat_ips                = var.reserve_nat_ip ? [google_compute_address.nat_ip[0].self_link] : null

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
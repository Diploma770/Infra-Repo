output "network_id" {
  description = "VPC network ID."
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "VPC network name."
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "Subnet ID."
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "Subnet name."
  value       = google_compute_subnetwork.subnet.name
}

output "router_name" {
  description = "Cloud Router name (if NAT enabled)."
  value       = var.enable_nat ? google_compute_router.router[0].name : null
}

output "nat_name" {
  description = "Cloud NAT name (if enabled)."
  value       = var.enable_nat ? google_compute_router_nat.nat[0].name : null
}

output "nat_ip" {
  description = "Static NAT egress IP (if reserved)."
  value       = (var.enable_nat && var.reserve_nat_ip) ? google_compute_address.nat_ip[0].address : null
}

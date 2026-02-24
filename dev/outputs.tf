output "ingress_static_ip_name" {
  description = "Global static IP name to use in Ingress annotation kubernetes.io/ingress.global-static-ip-name"
  value       = module.ingress_ip.name
}

output "ingress_static_ip_address" {
  description = "Reserved global static IP address for GKE Ingress"
  value       = module.ingress_ip.address
}

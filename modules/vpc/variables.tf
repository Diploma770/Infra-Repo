variable "network_name" {
  type        = string
  description = "Name of the VPC network."
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet."
}

variable "region" {
  type        = string
  description = "Region where the subnet will be created."
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR range for the subnet (e.g. 10.10.0.0/20)."
}

variable "enable_nat" {
  type        = bool
  description = "Enable Cloud NAT (needed for private GKE nodes egress)."
  default     = false
}

variable "reserve_nat_ip" {
  type        = bool
  description = "Reserve a static external IP for NAT egress."
  default     = false
}

variable "ssh_source_ranges" {
  type        = list(string)
  description = "List of CIDR ranges allowed to SSH (e.g. your public IP /32). Empty disables SSH rule."
  default     = []
}

variable "gke_master_ipv4_cidr" {
  type        = string
  description = "GKE master CIDR block for firewall rules (e.g. 172.16.0.0/28). Set to empty string to skip GKE firewall rules."
  default     = ""
}
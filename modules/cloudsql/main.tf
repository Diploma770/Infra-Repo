# TODO: change public sql to private

resource "google_sql_database_instance" "this" {
  name             = var.instance_name
  project          = var.project_id
  region           = var.region
  database_version = "POSTGRES_15" 

  settings {
    tier              = var.tier
    availability_type = "ZONAL" # no replicas/HA

    disk_type    = "PD_HDD"     # cheaper than SSD
    disk_size    = var.disk_size_gb
    disk_autoresize = true

    backup_configuration {
      enabled = true
    }

    ip_configuration {
    ipv4_enabled = true

        dynamic "authorized_networks" {
            for_each = var.authorized_networks
            content {
            name  = "allowed-${replace(authorized_networks.value, "/", "-")}"
            value = authorized_networks.value
            }
        }
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "db" {
  name     = var.db_name
  project  = var.project_id
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "user" {
  name     = var.db_user
  project  = var.project_id
  instance = google_sql_database_instance.this.name
  password = var.db_password
}

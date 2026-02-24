output "instance_connection_name" {
  value = google_sql_database_instance.this.connection_name
}

output "public_ip" {
  value = google_sql_database_instance.this.public_ip_address
}

output "db_name" {
  value = google_sql_database.db.name
}

output "db_user" {
  value = google_sql_user.user.name
}

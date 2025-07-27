output "instance_public_ip" {
  value       = ""                                          # The actual value to be outputted
  description = "The public IP address of the EC2 instance" # Description of what this output represents
}

output "db_url" {
  value       = "postgres://${google_sql_user.api.name}:${google_sql_user.api.password}@${google_sql_database_instance.pritt_db_main_pg.private_ip_address}/${google_sql_database.database.name}"
  description = "The public URL for accessing the SQL instance"
}
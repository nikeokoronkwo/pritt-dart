# Database Infra

locals {
  cases = {
    # TODO: Populate Cases
    default = {

    }

  }

  db_config = lookup(local.cases[var.tier], local.cases.default)
}

resource "google_sql_database_instance" "pritt_db_main_pg" {
  name             = "pritt-db-main-pg"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier                        = var.production ? "" : "db-f1-micro"
    deletion_protection_enabled = true


    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.pritt_network.self_link
      ssl_mode        = "ENCRYPTED_ONLY"
    }
  }

  depends_on = [google_service_networking_connection.db_private_vpc_connection]
}

resource "google_sql_database" "database" {
  name     = "pritt-registry-db"
  instance = google_sql_database_instance.pritt_db_main_pg.name
}

resource "google_sql_user" "api" {
  instance = google_sql_database_instance.pritt_db_main_pg.name
  name     = "api"
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length  = 16
  special = false
}


# IP Addr for Pritt DB
resource "google_compute_global_address" "db_private_ip_address" {
  name          = "db-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.pritt_network.id
}

# VPC connection for "db_private_ip_address"
resource "google_service_networking_connection" "db_private_vpc_connection" {
  network                 = google_compute_network.pritt_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db_private_ip_address.name]
}


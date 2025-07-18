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

  # settings {
  # }

  depends_on = []
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
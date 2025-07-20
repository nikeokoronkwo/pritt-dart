# S3 Compatible Storage Buckets
locals {
  location = "US"
}

resource "google_storage_bucket" "storage" {
  name          = "pritt-packages"
  location      = local.location
  force_destroy = true

  public_access_prevention = "enforced"
}

resource "google_storage_bucket" "publishing" {
  name          = "pritt-publishing-archives"
  location      = local.location
  force_destroy = true
}

resource "google_storage_bucket" "adapters" {
  name          = "pritt-adapters"
  location      = local.location
  force_destroy = true

  public_access_prevention = "enforced"


}
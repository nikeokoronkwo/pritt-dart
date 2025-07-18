# S3 Compatible Storage Buckets

resource "google_storage_bucket" "pritt_bucket" {
  location = var.region
  name     = ""
}
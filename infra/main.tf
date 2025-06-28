terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.38.0"
    }
  }
}

provider "google" {
  region = "us-central1"
  zone   = "us-central1-c"
}


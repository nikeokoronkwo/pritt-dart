terraform {
  backend "local" {
    path = "default.tfstate"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.44.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}


# Managing Pritt Images in GCP Registry (or other registry)

resource "google_artifact_registry_repository" "pritt_artifacts" {
  location      = var.region
  repository_id = "pritt-repo"
  format        = "DOCKER"
}

data "google_artifact_registry_docker_image" "pritt_server_image" {
  location      = google_artifact_registry_repository.pritt_artifacts.location
  repository_id = google_artifact_registry_repository.pritt_artifacts.repository_id
  # TODO: Image Versioning (most likely from tags)
  image_name = "pritt-server"
}
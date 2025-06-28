resource "google_cloud_run_v2_service" "server" {
  name     = "pritt_server"
  location = local.server_location
  
  template {
    containers {
      image = data.google_artifact_registry_docker_image.pritt_server_image.self_link
    }
  }
}
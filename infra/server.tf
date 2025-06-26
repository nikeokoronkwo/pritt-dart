resource "google_cloud_run_v2_service" "server" {
    name = "pritt_server"
    location = local.server_location
}
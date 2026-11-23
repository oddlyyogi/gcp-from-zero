resource "google_firestore_database" "db" {
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
}

resource "google_secret_manager_secret" "api_key" {
  secret_id = "snapshelf-api-key"
  replication {
    auto {}
  }
}

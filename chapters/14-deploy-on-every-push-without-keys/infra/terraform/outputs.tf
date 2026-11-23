output "api_url" {
  value = google_cloud_run_v2_service.api.uri
}

output "uploads_bucket" {
  value = google_storage_bucket.uploads.name
}

output "runtime_account" {
  value = google_service_account.run.email
}

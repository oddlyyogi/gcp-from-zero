resource "google_artifact_registry_repository" "images" {
  repository_id = "snapshelf"
  location      = var.region
  format        = "DOCKER"
  description   = "SnapShelf images"
  cleanup_policies {
    id     = "delete-untagged-old"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "604800s"
    }
  }
  cleanup_policies {
    id     = "keep-recent"
    action = "KEEP"
    most_recent_versions {
      keep_count = 5
    }
  }
}

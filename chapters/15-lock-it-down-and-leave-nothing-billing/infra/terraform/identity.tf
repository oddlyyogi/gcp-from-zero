resource "google_service_account" "run" {
  account_id   = "snapshelf-run"
  display_name = "SnapShelf runtime"
  description  = "Identity of the SnapShelf API"
}

resource "google_service_account" "deploy" {
  account_id   = "snapshelf-deploy"
  display_name = "SnapShelf deployer"
  description  = "Builds and deploys SnapShelf"
}

resource "google_service_account" "thumbs" {
  account_id   = "snapshelf-thumbs"
  display_name = "SnapShelf thumbnails"
}

resource "google_service_account" "events" {
  account_id   = "snapshelf-events"
  display_name = "SnapShelf event trigger"
}

resource "google_cloud_run_v2_service" "api" {
  name     = "snapshelf"
  location = var.region
  scaling {
    max_instance_count = 3
  }
  template {
    service_account = google_service_account.run.email
    containers {
      image = "${local.registry}/snapshelf/api:v6"
    }
  }
  lifecycle {
    ignore_changes = [
      template, traffic, client, client_version,
    ]
  }
}

resource "google_cloud_run_v2_service" "thumbs" {
  name     = "snapshelf-thumbs"
  location = var.region
  scaling {
    max_instance_count = 2
  }
  template {
    service_account = google_service_account.thumbs.email
    containers {
      image = "${local.registry}/cloud-run-source-deploy/snapshelf-thumbs"
    }
  }
  lifecycle {
    ignore_changes = [
      template, traffic, client, client_version, build_config,
    ]
  }
}

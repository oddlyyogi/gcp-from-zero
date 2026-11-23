resource "google_pubsub_topic" "events" {
  name   = "photo-events"
  labels = local.labels
}

resource "google_pubsub_topic" "dlq" {
  name   = "photo-events-dlq"
  labels = local.labels
}

resource "google_eventarc_trigger" "uploaded" {
  name            = "photo-uploaded"
  location        = var.region
  service_account = google_service_account.events.email
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  transport {
    pubsub {
      topic = google_pubsub_topic.events.id
    }
  }
  destination {
    cloud_run_service {
      service = google_cloud_run_v2_service.thumbs.name
      region  = var.region
    }
  }
}

import {
  to = google_compute_network.vpc
  id = "projects/${var.project_id}/global/networks/snapshelf-vpc"
}

import {
  to = google_compute_subnetwork.subnet
  id = "projects/${var.project_id}/regions/${var.region}/subnetworks/snapshelf-subnet"
}

import {
  to = google_compute_firewall.iap
  id = "projects/${var.project_id}/global/firewalls/snapshelf-allow-iap"
}

import {
  to = google_storage_bucket.uploads
  id = "${var.project_id}-uploads"
}

import {
  to = google_storage_bucket.thumbs
  id = "${var.project_id}-thumbs"
}

import {
  to = google_service_account.run
  id = "projects/${var.project_id}/serviceAccounts/snapshelf-run@${var.project_id}.iam.gserviceaccount.com"
}

import {
  to = google_service_account.deploy
  id = "projects/${var.project_id}/serviceAccounts/snapshelf-deploy@${var.project_id}.iam.gserviceaccount.com"
}

import {
  to = google_service_account.thumbs
  id = "projects/${var.project_id}/serviceAccounts/snapshelf-thumbs@${var.project_id}.iam.gserviceaccount.com"
}

import {
  to = google_service_account.events
  id = "projects/${var.project_id}/serviceAccounts/snapshelf-events@${var.project_id}.iam.gserviceaccount.com"
}

import {
  to = google_pubsub_topic.events
  id = "projects/${var.project_id}/topics/photo-events"
}

import {
  to = google_pubsub_topic.dlq
  id = "projects/${var.project_id}/topics/photo-events-dlq"
}

import {
  to = google_eventarc_trigger.uploaded
  id = "projects/${var.project_id}/locations/${var.region}/triggers/photo-uploaded"
}

import {
  to = google_artifact_registry_repository.images
  id = "projects/${var.project_id}/locations/${var.region}/repositories/snapshelf"
}

import {
  to = google_firestore_database.db
  id = "projects/${var.project_id}/databases/(default)"
}

import {
  to = google_secret_manager_secret.api_key
  id = "projects/${var.project_id}/secrets/snapshelf-api-key"
}

import {
  to = google_cloud_run_v2_service.api
  id = "projects/${var.project_id}/locations/${var.region}/services/snapshelf"
}

import {
  to = google_cloud_run_v2_service.thumbs
  id = "projects/${var.project_id}/locations/${var.region}/services/snapshelf-thumbs"
}

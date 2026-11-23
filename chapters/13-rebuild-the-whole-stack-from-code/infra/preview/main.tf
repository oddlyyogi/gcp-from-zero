terraform {
  required_version = ">= 1.10"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.12"
    }
  }
  backend "gcs" {
    prefix = "preview"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "image_tag" {
  type    = string
  default = "v6"
}

locals {
  registry = "${var.region}-docker.pkg.dev/${var.project_id}"
  image    = "${local.registry}/snapshelf/api:${var.image_tag}"
}

resource "google_service_account" "preview" {
  account_id   = "snapshelf-preview"
  display_name = "SnapShelf preview"
}

resource "google_storage_bucket" "preview" {
  name                        = "${var.project_id}-preview"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true
}

resource "google_cloud_run_v2_service" "preview" {
  name                = "snapshelf-preview"
  location            = var.region
  deletion_protection = false
  scaling {
    max_instance_count = 1
  }
  template {
    service_account = google_service_account.preview.email
    containers {
      image = local.image
      env {
        name  = "BUCKET"
        value = google_storage_bucket.preview.name
      }
      env {
        name  = "APP_VERSION"
        value = "preview-${var.image_tag}"
      }
    }
  }
}

output "url" {
  value = google_cloud_run_v2_service.preview.uri
}

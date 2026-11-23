variable "project_id" {
  type        = string
  description = "The SnapShelf project"
}

variable "region" {
  type    = string
  default = "us-central1"
}

locals {
  labels   = { app = "snapshelf", managed-by = "terraform" }
  registry = "${var.region}-docker.pkg.dev/${var.project_id}"
}

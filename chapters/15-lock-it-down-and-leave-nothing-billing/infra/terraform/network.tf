resource "google_compute_network" "vpc" {
  name                    = "snapshelf-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "snapshelf-subnet"
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = "10.10.0.0/24"
  private_ip_google_access = true
}

resource "google_compute_firewall" "iap" {
  name          = "snapshelf-allow-iap"
  network       = google_compute_network.vpc.id
  description   = "SSH and API through IAP only"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["snapshelf-vm"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}

provider "google" {
  project = "index-icos-sandbox-e9ddv7"
  region  = "europe-west4"
}

resource "google_compute_instance" "default" {
  name         = "vm-instance"
  machine_type = "e2-medium"
  zone         = "europe-west4-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

variable "project_id" {
  description = "The project ID to deploy resources"
  type        = string
}

provider "google" {
  project = "index-icos-sandbox-e9ddv7"
  region  = "eu-west4"
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
    network = "icostestnetwork"
    access_config {
    }
  }
}
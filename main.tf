provider "google" {
  project = "index-icos-sandbox-e9ddv7"
  region  = "europe-west4"
  zone    = "europe-west4-a"
}

resource "google_compute_instance" "default" {
  name         = "vm-instance"
  machine_type = "e2-medium"

  labels = {
    environment = "sandbox"
    purpose     = "test"
  }

  tags = ["web-server"]

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      echo "Startup script executed"
      apt-get update
      EOT
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20 # Size in GB
    }
  }

  network_interface {
    network = "icostestnetwork"
    access_config {
      // Ephemeral IP
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  service_account {
    email  = "default"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
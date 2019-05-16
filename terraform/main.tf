provider "google" {
  version = "1.4.0"
  credentials = "${file("account.json")}"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "app" {
  name         = "crawler-docker"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["crawler-docker"]
  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    script = "deploy.sh"
  }
}



resource "google_compute_firewall" "allow-port-8000" {
  name    = "allow-port-8000"
  network = "default"

  allow {
    protocol = "tcp"

    ports = ["8000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["crawler-docker"]
}

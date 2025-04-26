# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Configure opentofu backend to store state in GCS
terraform {

  required_version = ">= 1.6.0" # opentofu

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
  backend "gcs" {
    bucket = "learn-apache-443615-tfstate"
    prefix = "terraform/state"
  }
}

# Create a GCP bucket for CSV data files
# resource "google_storage_bucket" "data_bucket" {
#   name                        = var.data_bucket_name
#   location                    = var.region
#   force_destroy               = true
#   uniform_bucket_level_access = true
# }

# Upload CSV files to the data bucket
# resource "google_storage_bucket_object" "csv_files" {
#   for_each = var.csv_files

#   name   = each.key
#   source = each.value
#   bucket = google_storage_bucket.data_bucket.name
# }

# Create a VPC network
resource "google_compute_network" "elt_network" {
  name                    = "elt-network"
  auto_create_subnetworks = true
}

# Create firewall rules to allow specific ports
resource "google_compute_firewall" "allow_ports" {
  name    = "allow-elt-dbt-ports"
  network = google_compute_network.elt_network.name
  allow {
    protocol = "tcp"
    ports    = ["22", "5432", "4213", "4040-4050", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["elt-vm"]
}

# Create a static external IP
# resource "google_compute_address" "static_ip" {
#   name   = "elt-vm-static-ip"
#   region = var.region
# }

# Create a spot compute instance
resource "google_compute_instance" "elt_vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["elt-vm"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20250425"
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network = google_compute_network.elt_network.name
    access_config {}
    #   nat_ip = google_compute_address.static_ip.address
    # }
  }

  # Spot instance configuration
  scheduling {
    provisioning_model = "spot"
    preemptible        = true
    automatic_restart  = false
  }

}
resource "null_resource" "setup_vm" {
  depends_on = [google_compute_instance.elt_vm]

  connection {
    type        = "ssh"
    host        = google_compute_instance.elt_vm.network_interface[0].access_config[0].nat_ip
    user        = "ramdee"
    private_key = file("~/.ssh/ramdee_gcp/ramdee_gcp")
  }
  provisioner "remote-exec" {
    inline = [
      "cd ~",
      "sudo apt-get update && sudo apt-get install -y make git unzip",
      "git clone https://github.com/deepakramani/dbt-bike-insights.git",
      "cd dbt-bike-insights",
      "git checkout feature-terraform",
      "make install_docker",
      "make install_conda",
    ]
  }

}
output "instance_ip_address" {
  value       = google_compute_instance.elt_vm.network_interface[0].access_config[0].nat_ip #google_compute_address.static_ip.address
  description = "outputs the static public ip address"
}

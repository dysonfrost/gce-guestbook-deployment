resource "google_service_account" "guestbook_vm" {
  account_id   = "guestbook-vm"
  display_name = "Guestbook VM service account"
}

resource "google_compute_instance" "vm" {
  name         = "guestbook-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-13"
      type  = "pd-standard"
      size  = 30
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      # Assigns an ephemeral external IP.
    }
  }

  # Least privilege: the VM writes logs and metrics to GCP only.
  # No other GCP API access is granted.
  service_account {
    email = google_service_account.guestbook_vm.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  tags = ["http-server", "https-server", "ssh"]

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_project_iam_member" "vm_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.guestbook_vm.email}"
}

resource "google_project_iam_member" "vm_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.guestbook_vm.email}"
}

output "vm_public_ip" {
  description = "Ephemeral public IP address of the VM."
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "gcloud command to SSH into the VM."
  value       = "gcloud compute ssh ${google_compute_instance.vm.name} --zone=${var.zone} --project=${var.project_id}"
}

output "web_url" {
  description = "HTTPS URL for the VM."
  value       = "https://${google_compute_instance.vm.network_interface[0].access_config[0].nat_ip}"
}

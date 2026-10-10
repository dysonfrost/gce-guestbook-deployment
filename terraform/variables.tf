variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  default     = "europe-west9"
  description = "GCP region"
}

variable "zone" {
  type        = string
  default     = "europe-west9-b"
  description = "GCP zone"
}

variable "ssh_allowed_ips" {
  type        = list(string)
  description = "CIDR ranges allowed to SSH into the VM"
}

variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "GCE machine type"
}

variable "environment" {
  type        = string
  default     = "lab"
  description = "Deployment environment label"
}
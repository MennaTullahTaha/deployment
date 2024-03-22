variable "gcp_credentials" {
}

variable "gcp_region" {

}

variable "working_dir" {

}

variable "gke_zone" {
  type        = string
  description = "cluster zone"
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project id."
}

variable "gke_service_account_name" {
  type        = string
  description = "Service account name"
}
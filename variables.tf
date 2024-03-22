variable "gcp_credentials" {
}

variable "application_name" {

}

variable "gcp_region" {
  default     = "europe-west3-b"
  description = "Default region of the cluster"
}

variable "gke_cluster_name" {
  default     = "experimental-cluster"
  description = "Name of the cluster to deploy to"
}


variable "gcp_project_id" {
  default     = "deploying-with-terraform"
  description = "id of project created on google cloud"
}

variable "gke_service_account_name" {
  default     = "terraform-gke@deploying-with-terraform.iam.gserviceaccount.com"
  description = "Service account name"
}
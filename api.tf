resource "null_resource" "docker-registry" {
  
  provisioner "local-exec" { 
    working_dir = var.working_dir
    command = <<EOT
    cd ../api
    ls -a
    gcloud components install docker-credential-gcr && \
    docker-credential-gcr configure-docker && \
    docker build -t eu.gcr.io/${var.gcp_project_id}/api-skaffold:v1 . && \
    docker push eu.gcr.io/${var.gcp_project_id}/api-skaffold:v1
    cd ..
   EOT
  }
  depends_on = [google_project_service.containerregistry]
}

// This will create (if not existing) the storage bucket to host container images. 
// The access to this bucket is granted thanks to these 3 other sections of the template

data "google_client_config" "default" {}

/* Assign access to defualt service used by Kubernetes to bucket created for Container registry  */
resource "google_project_service" "containerregistry" {
  service          = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_namespace" "kn" {
  metadata {
    name = "api-skaffold-namespace"
  }
}

resource "kubernetes_deployment" "api_skaffold" {
  depends_on = [null_resource.docker-registry]
  
  metadata {
    name      = var.gcp_project_id
    namespace = kubernetes_namespace.kn.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.gcp_project_id
      }
    }
    template {
      metadata {
        labels = {
          app = var.gcp_project_id
        }
      }
      spec {
        container {
          image = "eu.gcr.io/${var.gcp_project_id}/api-skaffold:v1"
          name  = var.gcp_project_id
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api_skaffold_service" {
  metadata {
    name      = var.gcp_project_id
    namespace = kubernetes_namespace.kn.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.api_skaffold.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 3000
      target_port = 3000
    }
  }
}
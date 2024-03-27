resource "google_project_iam_member" "artifact_role" {
  role = "roles/artifactregistry.reader"
  member  = "serviceAccount:${var.gke_service_account_name}"
  project = var.gcp_project_id
}

resource "kubernetes_namespace" "nodejs" {
  metadata {
    name = "nodejs-namespace"
  }
}

resource "kubernetes_deployment" "api-skaffold" {  
  metadata {
    name      = "test"
    namespace = "nodejs-namespace"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "test"
      }
    }
    template {
      metadata {
        labels = {
          app = "test"
        }
      }
      spec {
        container {
          image = "europe-west3-docker.pkg.dev/deploying-with-terraform/express/api-skaffold:v1"
          name  = "test"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api-skaffold_service" {
  metadata {
    name      = "test"
    namespace = "nodejs-namespace"
  }
  spec {
    selector = {
      app = kubernetes_deployment.api-skaffold.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 3000
      target_port = 3000
    }
  }
}

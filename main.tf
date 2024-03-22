resource "kubernetes_namespace" "express" {
  metadata {
    name = "express-namespace"
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
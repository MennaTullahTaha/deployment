resource "kubernetes_namespace" "nodexpressv1" {
  metadata {
    name = "nodexpressv1-namespace"
  }
}

resource "kubernetes_deployment" "api_skaffold" {  
  metadata {
    name      = "test"
    namespace = kubernetes_namespace.nodexpressv1.metadata.0.name
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

resource "kubernetes_service" "api_skaffold_service" {
  metadata {
    name      = "test"
    namespace = "kubernetes_namespace.nodexpressv1.metadata.0.name"
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
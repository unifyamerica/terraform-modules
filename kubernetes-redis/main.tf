resource "kubernetes_deployment" "redis" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        container {
          name    = var.name
          image   = var.image
          command = ["redis-server"]
          args    = ["--save", "", "--appendonly", "no"]

          port {
            container_port = 6379
          }

          resources {
            requests = var.resources.requests
            limits   = var.resources.limits
          }

          readiness_probe {
            tcp_socket {
              port = 6379
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          liveness_probe {
            tcp_socket {
              port = 6379
            }
            initial_delay_seconds = 15
            period_seconds        = 30
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }
      }
    }
  }

}

resource "kubernetes_service" "redis" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = var.name
    }
  }

  spec {
    selector = {
      app = var.name
    }

    type = "ClusterIP"

    port {
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
    }
  }

  depends_on = [kubernetes_deployment.redis]
}


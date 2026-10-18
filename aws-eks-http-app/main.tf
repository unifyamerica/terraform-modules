resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = var.name
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "0"
        max_surge       = "1"
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
          name  = var.name
          image = var.image

          port {
            container_port = var.container_port
          }

          command = var.command
          args    = var.args
          resources {
            requests = var.resources.requests
            limits   = var.resources.limits
          }

          readiness_probe {
            http_get {
              path = var.healthcheck_path
              port = var.container_port
            }
            initial_delay_seconds = 15
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          liveness_probe {
            http_get {
              path = var.healthcheck_path
              port = var.container_port
            }
            initial_delay_seconds = 30
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          startup_probe {
            http_get {
              path = var.healthcheck_path
              port = var.container_port
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            failure_threshold     = 12
          }

          dynamic "env" {
            for_each = var.env_vars
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          dynamic "volume_mount" {
            for_each = var.tmp_mount_path == null ? [] : [var.tmp_mount_path]
            content {
              name       = "tmp"
              mount_path = volume_mount.value
            }
          }
        }

        dynamic "volume" {
          for_each = var.tmp_mount_path == null ? [] : [var.tmp_mount_path]
          content {
            name = "tmp"
            empty_dir {}
          }
        }
      }
    }
  }

}

resource "kubernetes_service" "app" {
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

    type = "NodePort"

    port {
      port        = var.service_port
      target_port = var.container_port
      protocol    = "TCP"
    }
  }

  depends_on = [kubernetes_deployment.app]
}

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace

    annotations = merge({
      "kubernetes.io/ingress.class"                            = "alb"
      "alb.ingress.kubernetes.io/scheme"                       = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"                  = "instance"
      "alb.ingress.kubernetes.io/listen-ports"                 = jsonencode([{ "HTTP" : 80 }, { "HTTPS" : 443 }])
      "alb.ingress.kubernetes.io/ssl-redirect"                 = "443"
      "alb.ingress.kubernetes.io/certificate-arn"              = var.certificate_arn
      "alb.ingress.kubernetes.io/healthcheck-path"             = var.healthcheck_path
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "60"
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = "40"
    }, var.ingress_annotations)
  }

  spec {
    rule {
      host = var.hostname

      http {
        path {
          path      = var.ingress_path
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.app]
}

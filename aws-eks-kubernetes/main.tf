data "aws_acm_certificate" "cert" {
  domain      = "${var.tls_cert_domain_name}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "kubernetes_namespace" "namespace" {
    metadata {
        name = "${var.environment}-${var.namespace}"
    }
}

resource "kubernetes_service" "service" {
    metadata {
      name = "web"
      namespace = kubernetes_namespace.namespace.metadata.0.name
    }
    spec {
      selector = {
        app = "web"
      }
      port {
        name = "http"
        protocol = "TCP"
        port = 80
        target_port = 8000
      }
      type = "NodePort"
    }
}

resource "kubernetes_deployment" "deployment" {
    metadata {
        name = "web"
        namespace = kubernetes_namespace.namespace.metadata.0.name
    }
    depends_on = [ 
      kubernetes_job.migrate
    ]
    spec {
        replicas = var.web_replica_count

        strategy {
          type = "RollingUpdate"
          rolling_update {
            max_unavailable = 0
            max_surge = 1
          }
        }
        selector {
            match_labels = {
                app = "web"
            }
        }
        template {
          metadata {
            labels = {
              app = "web"
            }
          }
          spec {
            container {
              name = "web"
              image = "${var.ecr_repo_url}:${var.image_tag}"
              image_pull_policy = "Always"
              args = ["gunicorn", "--workers", "9", "--timeout", "300", "dj.wsgi:application", "--bind", "0.0.0.0:8000"]
              port {
                container_port = 8000
              }
              env {
                name  = "KUBERNETES_LABEL"
                value = "web"
              }
              dynamic "env" {
                for_each = var.env_vars
                content {
                  name  = env.value.name
                  value = env.value.value
                }
              }
              resources {
                requests = {
                  cpu    = var.web_cpu_request
                  memory = var.web_memory_request
                }
              }

              readiness_probe {
                http_get {
                  path = "/health"
                  port = 8000
                }
                period_seconds = 5
                timeout_seconds = 2
                failure_threshold = 3
              }
              startup_probe {
                http_get {
                  path = "/health"
                  port = 8000
                }
                period_seconds = 5
                failure_threshold = 30
                timeout_seconds = 2
              }
              liveness_probe {
                http_get {
                  path = "/health"
                  port = 8000
                }
                period_seconds = 10
                failure_threshold = 3
                timeout_seconds = 2
              }
            }
            volume {
              name = "app-volume"
              empty_dir {
                
              }
            }
          }
        }
    }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "web"
    namespace = kubernetes_namespace.namespace.metadata.0.name
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "instance"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "${var.tg_healthcheck_interval}"
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" = "${var.tg_healthcheck_timeout}"
      "alb.ingress.kubernetes.io/load-balancer-name" = "${var.environment}-${var.namespace}-eks-alb"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80},{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect": "443"
      "alb.ingress.kubernetes.io/certificate-arn": "${data.aws_acm_certificate.cert.arn}"
      "kubernetes.io/ingress.class" = "alb"
    }
  }

  spec {
    default_backend {
      service {
        name = "web"
        port {
          number = 80
        }
      }
    }
  }
}

resource "kubernetes_deployment" "cron" {
    metadata {
        name = "cron"
        namespace = kubernetes_namespace.namespace.metadata.0.name
    }
    spec {
        replicas = var.cron_replica_count
        selector {
            match_labels = {
                app = "cron"
            }
        }
        template {
          metadata {
            labels = {
              app = "cron"
            }
          }
          spec {
            container {
              name = "cron"
              image = "${var.ecr_repo_url}:${var.image_tag}"
              image_pull_policy = "Always"
              args = ["crond", "-f"]
              port {
                container_port = 8000
              }
              env {
                name  = "KUBERNETES_LABEL"
                value = "cron"
              }
              dynamic "env" {
                for_each = var.env_vars
                content {
                  name  = env.value.name
                  value = env.value.value
                }
              }
              resources {
                requests = {
                  cpu    = var.cron_cpu_request
                  memory = var.cron_memory_request
                }
                limits = {
                  cpu    = var.cron_cpu_limit
                  memory = var.cron_memory_limit
                }
              }
            }
            volume {
              name = "cron-volume"
              empty_dir {
              }
            }
          }
        }
    }
}

resource "kubernetes_job" "migrate" {
  metadata {
    name = "django-migrate-${local.image_tag_sanitized}"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = "web"
      release = local.image_tag_sanitized
    }
  }

  spec {
    backoff_limit = 1
    ttl_seconds_after_finished = 3600

    template {
      metadata {
        labels = {
          app = "web"
          job = "django-migrate"
          release = local.image_tag_sanitized
        }
      }
      spec {
        restart_policy = "Never"

        container {
          name = "migrate"
          image = "${var.ecr_repo_url}:${var.image_tag}"
          image_pull_policy = "IfNotPresent"

          command = ["python", "manage.py", "migrate", "--noinput"]

          env {
            name = "KUBERNETES_LABEL"
            value = "migrate"
          }
          dynamic "env" {
            for_each = var.env_vars
            content {
              name = env.value.name
              value = env.value.value
            }
          }
        }
      }
    }
  }
}

resource "aws_eks_addon" "observability-addon" {
  count         = var.enable_cloudwatch_logs ? 1 : 0
  addon_version = "v3.4.0-eksbuild.1"
  cluster_name  = var.eks_cluster_id
  addon_name    = "amazon-cloudwatch-observability"
}

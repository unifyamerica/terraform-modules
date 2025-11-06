resource "kubernetes_horizontal_pod_autoscaler_v2" "web_app_hpa" {
  metadata {
    name = "web-hpa"
    namespace = "${var.environment}-${var.web_namespace}"
  }

  spec {
    max_replicas = 5
    min_replicas = 1

    # metric {
    #   type = "Resource"
    #   resource {
    #     name = "cpu"
    #     target {
    #       type  = "Utilization"
    #       average_utilization = "250"
    #     }
    #   }
    # }

    # metric {
    #   type = "Resource"
    #   resource {
    #     name = "memory"
    #     target {
    #       type  = "AverageValue"
    #       average_value = "1024Mi"
    #     }
    #   }
    # }
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "web"
    }

    target_cpu_utilization_percentage = 80
  }
}

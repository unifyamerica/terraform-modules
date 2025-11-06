resource "helm_release" "metrics_server" {
  name       = var.helm_name
  chart      = var.helm_chart
  repository = var.helm_repository
  version    = var.helm_chart_version
  namespace  = var.helm_metrics_namespace
}

output "deployment_name" {
  description = "Application deployment name."
  value       = kubernetes_deployment.app.metadata[0].name
}
output "service_name" {
  description = "HTTP service name."
  value       = kubernetes_service.app.metadata[0].name
}
output "alb_dns_name" {
  description = "ALB hostname; null until the ingress controller has provisioned it."
  value       = try(kubernetes_ingress_v1.app.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "host" {
  description = "In-cluster Redis DNS hostname, available after the service is created."
  value       = "${kubernetes_service.redis.metadata[0].name}.${var.namespace}.svc.cluster.local"
}
output "url" {
  description = "Plaintext in-cluster Redis URL. This module does not enable AUTH or TLS."
  value       = "redis://${kubernetes_service.redis.metadata[0].name}.${var.namespace}.svc.cluster.local:6379"
}

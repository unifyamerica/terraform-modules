output "migration_job_name" {
  value = kubernetes_job.migrate.metadata[0].name
}

output "kube_namespace" {
  value = kubernetes_namespace.namespace.metadata[0].name
}

mock_provider "kubernetes" {}
variables {
  name      = "test-cache"
  namespace = "existing-apps"
}
run "service_reaches_disposable_cache" {
  command = apply
  assert {
    condition = (
      output.host == "${kubernetes_service.redis.metadata[0].name}.${var.namespace}.svc.cluster.local" &&
      kubernetes_service.redis.spec[0].selector.app == kubernetes_deployment.redis.spec[0].template[0].metadata[0].labels.app &&
      kubernetes_service.redis.spec[0].port[0].target_port == tostring(kubernetes_deployment.redis.spec[0].template[0].spec[0].container[0].port[0].container_port) &&
      kubernetes_deployment.redis.spec[0].template[0].spec[0].container[0].args == tolist(["--save", "", "--appendonly", "no"])
    )
    error_message = "The output must locate the selected Redis pod, with both persistence mechanisms disabled."
  }
}

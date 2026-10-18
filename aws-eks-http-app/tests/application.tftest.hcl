mock_provider "kubernetes" {}
variables {
  name             = "test-api"
  namespace        = "existing-apps"
  image            = "registry.example.invalid/api:release"
  hostname         = "api.example.invalid"
  certificate_arn  = "arn:aws:acm:us-west-2:123456789012:certificate/test"
  container_port   = 8080
  service_port     = 81
  healthcheck_path = "/ready"
  env_vars         = [{ name = "AUTH", value = "test-only" }]
}
run "routes_to_the_configured_container" {
  command = apply
  assert {
    condition = (
      kubernetes_service.app.spec[0].port[0].target_port == tostring(kubernetes_deployment.app.spec[0].template[0].spec[0].container[0].port[0].container_port) &&
      kubernetes_ingress_v1.app.spec[0].rule[0].http[0].path[0].backend[0].service[0].name == output.service_name &&
      kubernetes_ingress_v1.app.spec[0].rule[0].http[0].path[0].backend[0].service[0].port[0].number == kubernetes_service.app.spec[0].port[0].port &&
      kubernetes_service.app.spec[0].selector.app == kubernetes_deployment.app.spec[0].template[0].metadata[0].labels.app
    )
    error_message = "Ingress and service must route to the selected deployment and its configured container port."
  }
  assert {
    condition = (
      kubernetes_deployment.app.spec[0].template[0].spec[0].container[0].readiness_probe[0].http_get[0].path == var.healthcheck_path &&
      kubernetes_ingress_v1.app.metadata[0].annotations["alb.ingress.kubernetes.io/healthcheck-path"] == var.healthcheck_path &&
      kubernetes_deployment.app.spec[0].template[0].spec[0].container[0].env[0].value == var.env_vars[0].value &&
      length(kubernetes_deployment.app.spec[0].template[0].spec[0].volume) == 0
    )
    error_message = "Caller health path and sensitive environment must reach the workload; no temporary volume is created by default."
  }
}
run "optional_temporary_storage" {
  command = apply
  variables { tmp_mount_path = "/work" }
  assert {
    condition = (
      kubernetes_deployment.app.spec[0].template[0].spec[0].container[0].volume_mount[0].mount_path == "/work" &&
      kubernetes_deployment.app.spec[0].template[0].spec[0].container[0].volume_mount[0].name == kubernetes_deployment.app.spec[0].template[0].spec[0].volume[0].name
    )
    error_message = "The optional container mount must reference the created temporary volume."
  }
}

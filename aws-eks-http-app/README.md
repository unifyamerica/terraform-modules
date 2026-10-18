# EKS HTTP application

Deploy one containerized HTTP application onto an existing EKS cluster. This module
owns a Kubernetes deployment, NodePort service, and host-routed ALB ingress. It
requires the AWS Load Balancer Controller to be installed already. It provisions no
cluster, namespace, certificates, secrets, Redis, DNS, or IAM resources.

```hcl
module "web" {
  source = "../aws-eks-http-app"
  providers = { kubernetes = kubernetes }
  name = "example-api"
  namespace = "example"
  image = "registry.example.org/example-api:release"
  hostname = "api.example.org"
  certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/example"
  container_port = 3000
  healthcheck_path = "/ping"
  env_vars = [{ name = "APP_ENV", value = "production" }]
  resources = {
    requests = { cpu = "150m", memory = "512Mi" }
    limits = { memory = "1024Mi" }
  }
  tmp_mount_path = "/tmp"
}
```

Required inputs: `name`, `namespace`, `image`, `hostname`, and `certificate_arn`.
Optional inputs: `container_port` and `service_port` (80), `replica_count` (2),
`healthcheck_path` (`/`), `resources`, sensitive `env_vars` (empty), `command` and
`args` (null to retain image defaults), `tmp_mount_path` (null disables the volume),
`ingress_path` (`/*`), and `ingress_annotations` (merged after default annotations).

Readiness, liveness, and startup HTTP probes use the container port and health path.
Rolling updates permit one extra pod and zero unavailable pods. The ALB is
internet-facing with HTTP-to-HTTPS redirect and instance targets. Use annotations
for controller-specific configuration. The caller supplies the certificate in the
cluster's AWS region and creates DNS after `alb_dns_name` becomes available.

Outputs are `deployment_name`, `service_name`, and nullable `alb_dns_name`.
Environment values are sensitive but still appear in Terraform state. Keep remote
state protected. Providers are configured by the caller; no AWS or Helm provider
is needed by this module. On a new cluster, bootstrap EKS before planning workloads.

This is a new module. Existing `aws-eks-kubernetes` Django consumers are unchanged.
When extracting existing workloads, add caller-level `moved` blocks targeting
`kubernetes_deployment.app`, `kubernetes_service.app`, and
`kubernetes_ingress_v1.app`, and preserve names, namespace, labels, and settings.

Validate with `terraform init -backend=false`, `terraform validate`, and
`terraform test` (tests require Terraform 1.7+ and use a mocked Kubernetes provider).

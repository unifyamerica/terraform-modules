# Kubernetes Redis

A single, disposable Redis pod and ClusterIP service in a caller-owned namespace.
This module provides no persistence, replication, TLS, or authentication. Use a
managed Redis module when availability or encrypted/authenticated access is needed.

```hcl
module "cache" {
  source = "../kubernetes-redis"
  providers = { kubernetes = kubernetes }
  name = "example-redis"
  namespace = "example"
}
```

Required inputs are `name` and `namespace`. Optional `image` defaults to
`public.ecr.aws/docker/library/redis:7-alpine`. Optional `resources` sets requests
(default CPU `25m`, memory `64Mi`) and limits (memory `128Mi`). Redis uses port 6379
and runs with both RDB saves and AOF disabled. TCP probes monitor readiness/liveness.
Outputs `host` and `url` reference the created service and its existing namespace.

The caller configures the Kubernetes provider and creates the namespace. To move
existing resources into this module, add caller-level `moved` blocks targeting
`kubernetes_deployment.redis` and `kubernetes_service.redis` without changing their
names or namespace.

Validate with `terraform init -backend=false`, `terraform validate`, and
`terraform test` (mocked providers, Terraform 1.7+ for tests).

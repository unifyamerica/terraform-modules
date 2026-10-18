# Terraform modules

Reusable AWS and Kubernetes modules. Each module has its own provider requirements
and caller-configured providers.

- [aws-eks-cluster](aws-eks-cluster): EKS and its load balancer controller.
- [aws-eks-http-app](aws-eks-http-app): generic container HTTP deployment, service,
  health probes, and ALB ingress on an existing EKS cluster.
- [kubernetes-redis](kubernetes-redis): disposable in-cluster Redis for nonproduction.
- [aws-elasticache-redis](aws-elasticache-redis): managed Redis OSS with optional
  TLS/AUTH, encryption, explicit naming, and caller-owned ingress.
- [aws-eks-kubernetes](aws-eks-kubernetes): existing Django workload module;
  its consumers and behavior are unchanged by the generic HTTP module.

Compose cluster, HTTP application, and cache modules in environment roots. Keep
backend state, provider configuration, namespaces, application-specific credentials,
certificates, and DNS in the caller. Pin published Git sources to a reviewed commit
or release tag. Local module paths are useful during coordinated development.

variable "image_tag" {
    description = "Tag for the container image"
}

variable "ecr_repo_url" {
    description = "ECR Repo URL"
}

variable "cron_replica_count" {
    description = "Number of Cron Containers. Set this to zero to turn off cron in EKS"
}

variable "web_replica_count" {
    description = "Number of Web Containers."
}

variable "env_vars" {
  description = "Environment variables for Kubernetes deployment"
  type        = list(object({
    name  = string
    value = string
  }))
}

variable "aws_eks_worker_role_arn" {
    description = "AWS EKS Worker Role Arn"
}


variable "namespace" {
    description = "Kubernetes namespace"
}

variable "environment" {
    description = "Deployment environment"
}

variable "web_cpu_request" {
    description = "Requested CPU for Web Pod"
}

variable "web_memory_request" {
    description = "Requested Memory for Web Pod"
}

variable "cron_cpu_request" {
    description = "Requested CPU for Cron Pod"
}

variable "cron_memory_request" {
    description = "Requested Memory for Cron Pod"
}

variable "cron_cpu_limit" {
    description = "Limit CPU for Cron Pod"
}

variable "cron_memory_limit" {
    description = "Limit Memory for Cron Pod"
}

variable "tls_cert_domain_name" {
    description = "Domain Name of TLS Cert to use for Frontend ELB"
}

variable "eks_cluster_id" {
    description = "EKS Cluster ID"
}

variable "aws_region" {
    description = "Region where EKS infra is deployed"
}

variable "enable_cloudwatch_logs" {
    description = "Set this variable to enable cloudwatch logs. Disabled by default"
    default = false
}

variable "tg_healthcheck_interval" {
    description = "Specifies the interval(in seconds) between health check of an individual target"
    default = 60
}

variable "tg_healthcheck_timeout" {
    description = "Specifies the timeout(in seconds) during which no response from a target means a failed health check"
    default = 40
}

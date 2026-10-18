variable "name" {
  description = "Deployment, container, service, ingress, and app selector name."
  type        = string
}
variable "namespace" {
  description = "Existing namespace; the caller owns its lifecycle."
  type        = string
}
variable "image" {
  description = "Complete container image reference including tag or digest."
  type        = string
}
variable "hostname" {
  description = "DNS hostname routed by the ALB ingress."
  type        = string
}
variable "certificate_arn" {
  description = "Existing ACM certificate ARN in the ALB region."
  type        = string
}
variable "container_port" {
  description = "HTTP port exposed by the container and health probes."
  type        = number
  default     = 80
}
variable "service_port" {
  description = "HTTP service port targeted by the ALB."
  type        = number
  default     = 80
}
variable "replica_count" {
  description = "Number of application replicas."
  type        = number
  default     = 2
}
variable "healthcheck_path" {
  description = "Unauthenticated HTTP health endpoint for probes and ALB checks."
  type        = string
  default     = "/"
}
variable "resources" {
  description = "Kubernetes container requests and limits."
  type = object({
    requests = map(string)
    limits   = map(string)
  })
  default = {
    requests = { cpu = "150m", memory = "512Mi" }
    limits   = { memory = "1024Mi" }
  }
}
variable "env_vars" {
  description = "Container environment values. Sensitive values remain redacted in plans."
  type        = list(object({ name = string, value = string }))
  sensitive   = true
  default     = []
}
variable "command" {
  description = "Optional container entrypoint override; null preserves the image entrypoint."
  type        = list(string)
  default     = null
}
variable "args" {
  description = "Optional container arguments; null preserves the image arguments."
  type        = list(string)
  default     = null
}
variable "tmp_mount_path" {
  description = "Optional writable emptyDir mount; null creates no temporary volume."
  type        = string
  default     = null
}
variable "ingress_path" {
  description = "ALB host rule path (ImplementationSpecific matching)."
  type        = string
  default     = "/*"
}
variable "ingress_annotations" {
  description = "Additional ALB annotations, merged after the module defaults."
  type        = map(string)
  default     = {}
}

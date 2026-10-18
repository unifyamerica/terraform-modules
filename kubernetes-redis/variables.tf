variable "name" {
  description = "Redis deployment, service, container, and app selector name."
  type        = string
}
variable "namespace" {
  description = "Existing namespace; the caller owns its lifecycle."
  type        = string
}
variable "image" {
  description = "Redis image reference; pin a digest if immutable deployment is required."
  type        = string
  default     = "public.ecr.aws/docker/library/redis:7-alpine"
}
variable "resources" {
  description = "Kubernetes container requests and limits."
  type = object({
    requests = map(string)
    limits   = map(string)
  })
  default = {
    requests = { cpu = "25m", memory = "64Mi" }
    limits   = { memory = "128Mi" }
  }
}

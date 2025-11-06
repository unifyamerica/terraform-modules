variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "source_security_group_id" {
  description = "Source of SG where redis traffic is coming from"
  type = string
}

variable "replication_group" {
  description = "Name for the new Redis replication group"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t2.small"
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}

variable "parameter_group_name" {
  description = "Parameter group to use"
  type        = string
  default     = "default.redis7"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (primary and replicas) this replication group will have"
  default = 1
}
variable "port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "apply_immediately" {
    description = "Apply change immediately or wait for maintenance window"
    type = bool
    default = true
}

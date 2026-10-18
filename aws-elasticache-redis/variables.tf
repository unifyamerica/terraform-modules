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
  type        = string
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
  default     = 1
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
  type        = bool
  default     = true
}

variable "replication_group_id" {
  description = "Optional full replication group ID; null preserves the legacy environment-based name."
  type        = string
  default     = null
}

variable "description" {
  description = "Replication group description; default preserves the existing module value."
  type        = string
  default     = "Redis OOS Cache"
}

variable "subnet_group_name" {
  description = "Optional full subnet group name; null uses replication_group."
  type        = string
  default     = null
}

variable "subnet_group_description" {
  description = "Optional subnet group description; null uses provider default."
  type        = string
  default     = null
}

variable "security_group_name_prefix" {
  description = "Optional exact security group prefix; null preserves the legacy prefix."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Optional security group description; null uses provider default."
  type        = string
  default     = null
}

variable "network_tags" {
  description = "Tags for subnet and security groups; default preserves existing untagged resources."
  type        = map(string)
  default     = {}
}

variable "create_ingress_rule" {
  description = "Create the legacy source-SG ingress rule; false lets callers manage their own rule."
  type        = bool
  default     = true
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover; requires at least two cache clusters."
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ; requires an available replica."
  type        = bool
  default     = true
}

variable "cluster_mode" {
  description = "Optional cluster mode (disabled, compatible, enabled); null preserves existing behavior."
  type        = string
  default     = null
}

variable "at_rest_encryption_enabled" {
  description = "Optional encryption at rest; null preserves the provider default."
  type        = bool
  default     = null
}

variable "transit_encryption_enabled" {
  description = "Optional TLS configuration; null preserves existing behavior."
  type        = bool
  default     = null
}

variable "transit_encryption_mode" {
  description = "Optional TLS mode (preferred or required)."
  type        = string
  default     = null
}

variable "auth_token" {
  description = "Optional AUTH token; requires TLS. Stored in Terraform state."
  type        = string
  default     = null
  sensitive   = true
}

variable "snapshot_retention_limit" {
  description = "Backup retention in days; zero disables scheduled snapshots, null preserves existing behavior."
  type        = number
  default     = null
}

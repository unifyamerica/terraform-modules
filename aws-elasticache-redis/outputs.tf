output "new_primary_endpoint" {
  description = "Primary endpoint of Redis cluster"
  value       = aws_elasticache_replication_group.redis_oss.primary_endpoint_address
}

output "security_group_id" {
  description = "Redis security group ID, for callers managing their own ingress rules."
  value       = aws_security_group.redis_security_group.id
}
output "port" {
  description = "Redis listening port."
  value       = aws_elasticache_replication_group.redis_oss.port
}

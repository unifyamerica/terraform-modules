output "new_primary_endpoint" {
  description = "Primary endpoint of Redis cluster"
  value       = aws_elasticache_replication_group.redis_oss.primary_endpoint_address
}

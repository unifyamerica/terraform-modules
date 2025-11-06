resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name        = var.replication_group
  subnet_ids  = var.subnet_ids
}


resource "aws_security_group" "redis_security_group" {
    name_prefix = "${var.environment}-redis-${var.replication_group}"
    vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "redis_ingress_from_sg" {
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis_security_group.id
  source_security_group_id = var.source_security_group_id
}

resource "aws_elasticache_replication_group" "redis_oss" {
  replication_group_id          = "${var.environment}-redis-${var.replication_group}"
  description                   = "Redis OOS Cache"
  num_cache_clusters            = var.num_cache_clusters
  node_type                     = var.node_type
  automatic_failover_enabled    = true
  multi_az_enabled              = true
  engine                        = "redis"
  engine_version                = var.engine_version
  parameter_group_name          = var.parameter_group_name
  port                          = var.port

  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [aws_security_group.redis_security_group.id]

  apply_immediately = var.apply_immediately

  tags = var.tags
}



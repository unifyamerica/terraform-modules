resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name        = coalesce(var.subnet_group_name, var.replication_group)
  description = var.subnet_group_description
  tags        = var.network_tags
  subnet_ids  = var.subnet_ids
}


resource "aws_security_group" "redis_security_group" {
  name_prefix = coalesce(var.security_group_name_prefix, "${var.environment}-redis-${var.replication_group}")
  description = var.security_group_description
  tags        = var.network_tags
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "redis_ingress_from_sg" {
  count                    = var.create_ingress_rule ? 1 : 0
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis_security_group.id
  source_security_group_id = var.source_security_group_id
}

resource "aws_elasticache_replication_group" "redis_oss" {
  replication_group_id       = coalesce(var.replication_group_id, "${var.environment}-redis-${var.replication_group}")
  description                = var.description
  num_cache_clusters         = var.num_cache_clusters
  node_type                  = var.node_type
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled
  engine                     = "redis"
  engine_version             = var.engine_version
  parameter_group_name       = var.parameter_group_name
  port                       = var.port

  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [aws_security_group.redis_security_group.id]

  cluster_mode               = var.cluster_mode
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  transit_encryption_mode    = var.transit_encryption_mode
  auth_token                 = var.auth_token
  snapshot_retention_limit   = var.snapshot_retention_limit

  lifecycle {
    precondition {
      condition     = var.auth_token == null ? true : can(regex("^[a-zA-Z0-9!&#$^<>-]{16,128}$", var.auth_token))
      error_message = "auth_token must contain 16-128 alphanumeric characters or these symbols: ! & # $ ^ < > -"
    }
    precondition {
      condition     = var.auth_token == null ? true : var.transit_encryption_enabled == true
      error_message = "AUTH requires transit_encryption_enabled = true."
    }
  }

  apply_immediately = var.apply_immediately

  tags = var.tags
}



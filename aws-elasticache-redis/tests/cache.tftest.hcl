mock_provider "aws" {}
variables {
  environment              = "test"
  replication_group        = "cache"
  vpc_id                   = "vpc-0123456789abcdef0"
  subnet_ids               = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  source_security_group_id = "sg-0123456789abcdef0"
  num_cache_clusters       = 2
}
run "legacy_contract" {
  command = apply
  assert {
    condition = (
      aws_elasticache_replication_group.redis_oss.replication_group_id == "test-redis-cache" &&
      aws_elasticache_subnet_group.redis_subnet_group.name == "cache" &&
      aws_security_group.redis_security_group.name_prefix == "test-redis-cache" &&
      aws_security_group_rule.redis_ingress_from_sg[0].security_group_id == output.security_group_id &&
      aws_security_group_rule.redis_ingress_from_sg[0].source_security_group_id == var.source_security_group_id
    )
    error_message = "Existing names and worker access must remain compatible with legacy consumers."
  }
}
run "secure_external_ingress" {
  command = apply
  variables {
    replication_group_id       = "test-api-redis"
    subnet_group_name          = "test-api-redis"
    security_group_name_prefix = "test-api-redis-"
    create_ingress_rule        = false
    transit_encryption_enabled = true
    transit_encryption_mode    = "required"
    at_rest_encryption_enabled = true
    auth_token                 = "TestOnlyToken1234!"
    cluster_mode               = "disabled"
    snapshot_retention_limit   = 0
  }
  assert {
    condition = (
      length(aws_security_group_rule.redis_ingress_from_sg) == 0 &&
      one(aws_elasticache_replication_group.redis_oss.security_group_ids) == output.security_group_id &&
      aws_elasticache_replication_group.redis_oss.subnet_group_name == aws_elasticache_subnet_group.redis_subnet_group.name &&
      aws_elasticache_replication_group.redis_oss.replication_group_id == "test-api-redis"
    )
    error_message = "External-rule callers must keep their cache identity and receive the attached security group."
  }
}
run "reject_auth_without_tls" {
  command = plan
  variables {
    auth_token                 = "TestOnlyToken1234!"
    transit_encryption_enabled = false
  }
  expect_failures = [aws_elasticache_replication_group.redis_oss]
}
run "reject_invalid_auth_token" {
  command = plan
  variables {
    auth_token                 = "InvalidTokenWith@"
    transit_encryption_enabled = true
  }
  expect_failures = [aws_elasticache_replication_group.redis_oss]
}

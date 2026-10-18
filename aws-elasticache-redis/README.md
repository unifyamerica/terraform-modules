# ElastiCache Redis OSS

Provision a Redis OSS replication group, subnet group, security group, and optional
source-security-group ingress rule. Configure the AWS provider in the caller.

Existing required inputs remain `environment`, `vpc_id`, `source_security_group_id`,
`replication_group`, and `subnet_ids`. Existing defaults and `new_primary_endpoint`
output are retained. In particular, existing naming is:

- Replication group ID: `${environment}-redis-${replication_group}`.
- Subnet group name: `${replication_group}`.
- Security group prefix: `${environment}-redis-${replication_group}`.

The legacy defaults enable Multi-AZ and failover but default to one cache cluster.
For a valid highly available deployment, explicitly use `num_cache_clusters = 2`
or more; for a single-node cache, explicitly disable both availability options.
This update preserves these defaults rather than changing existing callers.

## Secure configuration

```hcl
module "cache" {
  source = "../aws-elasticache-redis"
  environment = "production"
  replication_group = "api"
  vpc_id = var.vpc_id
  subnet_ids = var.private_subnet_ids
  source_security_group_id = var.worker_security_group_id
  node_type = "cache.t4g.micro"
  num_cache_clusters = 2
  cluster_mode = "disabled"
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  transit_encryption_mode = "required"
  auth_token = var.redis_auth_token
  snapshot_retention_limit = 0
}
```

`auth_token` is sensitive and optional. It requires TLS and must contain 16-128
alphanumeric characters or the symbols `! & # $ ^ < > -`.
See [AWS AUTH requirements](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/auth.html).
It is stored in Terraform state; this module neither creates nor updates secrets.
The provider's default token update strategy is ROTATE; retiring a previous token
requires a coordinated SET operation. Use `rediss://` in TLS-enabled clients and
URL-encode passwords embedded in connection URLs.

New optional inputs `replication_group_id`, `subnet_group_name`, and
`security_group_name_prefix` override full names for callers migrating existing
resources. Optional `description`, `subnet_group_description`, and
`security_group_description` preserve resource descriptions. `network_tags` applies
tags to subnet/security groups (default empty preserves legacy metadata); existing
`tags` still applies to the replication group. `automatic_failover_enabled` and
`multi_az_enabled` default true. Security, cluster mode, and backup inputs default
null to retain existing provider behavior. No final snapshot is requested by this
module. Existing `apply_immediately` still defaults true.

Set `create_ingress_rule = false` to manage access rules outside this module.
Additional outputs `security_group_id` and `port` support this composition.
For backwards state compatibility, `moved.tf` moves the original ingress rule to
its optional `[0]` address. Keep this file when upgrading existing deployments.
Terraform 1.2+ is now required for move declarations and AUTH preconditions; tests require 1.7+.

Validate using `terraform init -backend=false`, `terraform validate`, and
`terraform test`. Tests mock AWS and cover legacy naming, external-rule composition,
and rejection of insecure/invalid AUTH configuration without accessing AWS.

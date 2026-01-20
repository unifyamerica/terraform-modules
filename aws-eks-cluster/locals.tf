locals {
  name = "${var.environment}-${var.cluster_name}"

  common_tags = merge(var.tags, {
    Environment = var.environment
    Terraform   = "true"
  })

  access_entries = {
    for u in var.map_users : u.username => {
      principal_arn = u.userarn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  base_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  addons = merge(
    local.base_addons,
    var.enable_cloudwatch_logs ? {
      amazon-cloudwatch-observability = {
        addon_version = "v5.1.0-eksbuild.1"
      }
    } : {}
  )
}

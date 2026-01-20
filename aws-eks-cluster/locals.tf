locals {
  name = "${var.environment}-${var.cluster_name}"

  common_tags = merge(var.tags, {
    Environment = var.environment
    Terraform   = "true"
  })

  access_entries = {
    for u in var.map_users :
    u.username => {
      principal_arn     = u.userarn
      user_name         = u.username
      kubernetes_groups = u.groups
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
        most_recent = true
      }
    } : {}
  )
}

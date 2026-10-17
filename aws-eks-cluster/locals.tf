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
      addon_version = "v1.13.1-eksbuild.1"
    }
    kube-proxy = {
      addon_version = "v1.33.7-eksbuild.2"
    }
    vpc-cni = {
      addon_version = "v1.21.1-eksbuild.1"
    }
  }

  addons = merge(
    local.base_addons,
    var.enable_cloudwatch_logs ? {
      amazon-cloudwatch-observability = {
        addon_version = "v5.1.0-eksbuild.1"
        configuration_values = jsonencode({
          manager = {
            applicationSignals = {
              autoMonitor = {
                monitorAllServices = false
              }
            }
          }
        })
      }
    } : {}
  )
}

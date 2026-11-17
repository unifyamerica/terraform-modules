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
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  # Select AWS default add-on versions compatible with var.cluster_version.
  base_addons = {
    coredns = {
      most_recent = false
    }
    kube-proxy = {
      most_recent = false
    }
    vpc-cni = {
      most_recent = false
    }
  }

  addons = merge(
    local.base_addons,
    var.enable_cloudwatch_logs ? {
      amazon-cloudwatch-observability = {
        most_recent = false
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

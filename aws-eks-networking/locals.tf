locals {
  kube_cluster_name = "${var.environment}-${var.vpc_name}"
  default_tags = {
    "kubernetes.io/cluster/${local.kube_cluster_name}" = "shared"
  }
  default_public_subnet_tags  = {
    "kubernetes.io/cluster/${local.kube_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
  default_private_subnet_tags = {
    "kubernetes.io/cluster/${local.kube_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
  tags                        = merge(local.default_tags, var.additional_tags)
  public_subnet_tags          = merge(local.default_public_subnet_tags, var.additional_public_subnet_tags)
  private_subnet_tags         = merge(local.default_private_subnet_tags, var.additional_private_subnet_tags)
}

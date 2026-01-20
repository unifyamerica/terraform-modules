module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.14.0"

  name               = "${var.environment}-${var.cluster_name}"
  kubernetes_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa = true
  create_kms_key = false
  authentication_mode                    = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  access_entries                         = local.access_entries

  addons = local.addons

  self_managed_node_groups = {
    main = {
      name           = "${var.environment}-${var.cluster_name}-ng"
      instance_types = [var.instance_type]

      min_size     = 1
      max_size     = max(2, var.worker_count)
      desired_size = var.worker_count

      iam_role_additional_policies = merge(
        {
          CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
        },
        {
          FluentBitCloudWatchAccess = aws_iam_policy.fluentbit_cloudwatch_access.arn
        }
      )
    }
  }

  node_security_group_additional_rules = var.allow_nodeport_from_vpc ? {
    ingress_nodeports_from_vpc = {
      description = "Allow NodePort range from VPC (ALB instance targets hit nodeports)"
      protocol    = "tcp"
      from_port   = 30000
      to_port     = 32767
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr_block]
    }
  } : {}

  tags = var.tags
}

module "lb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "5.41.0"

  role_name = "${var.environment}_${var.cluster_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.7.2"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "image.repository"
    value = var.controller_image_repo
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = "${var.environment}-${var.cluster_name}"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [ module.eks ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [ module.eks ]
}

resource "kubernetes_service_account" "service-account" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name"= "aws-load-balancer-controller"
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.lb_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "aws_iam_policy" "fluentbit_cloudwatch_access" {
  name   = "${var.environment}_${var.cluster_name}-fluentbit-cloudwatch-access"
  path   = "/"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutRetentionPolicy"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

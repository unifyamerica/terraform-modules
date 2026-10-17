module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "17.24.0"
    cluster_name = "${var.environment}-${var.cluster_name}"
    cluster_version = var.cluster_version
    subnets = var.private_subnets
    vpc_id = var.vpc_id
    enable_irsa = true
    workers_group_defaults = {
        root_volume_type = "gp2"
    }
    worker_groups = [
        {
            name                          = "${var.environment}-${var.cluster_name}-worker-group"
            instance_type                 = var.instance_type
            additional_userdata           = "echo nothing"
            additional_security_group_ids = [var.additional_security_group_ids]
            asg_desired_capacity          = var.worker_count
        },
    ]
    workers_additional_policies = [
      aws_iam_policy.fluentbit_cloudwatch_access.arn,
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    ]
    map_roles = [
        {
            rolearn  = module.eks.worker_iam_role_arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups = [
                "system:bootstrappers",
                "system:nodes",
            ]
        }
    ]
    map_users = var.map_users
    tags      = var.tags
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

data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
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

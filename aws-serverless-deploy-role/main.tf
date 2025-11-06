data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.allowed_subjects
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "deploy" {
  statement {
    effect = "Allow"
    actions = ["cloudformation:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:*","apigateway:*","logs:*","events:*","cloudwatch:*","s3:*",
      "iam:CreateRole","iam:DeleteRole","iam:AttachRolePolicy","iam:DetachRolePolicy",
      "iam:PutRolePolicy","iam:DeleteRolePolicy","iam:PassRole"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["secretsmanager:GetSecretValue","secretsmanager:DescribeSecret","rds:Describe*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "deploy" {
  name   = "${var.role_name}-policy"
  policy = data.aws_iam_policy_document.deploy.json
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.deploy.arn
}

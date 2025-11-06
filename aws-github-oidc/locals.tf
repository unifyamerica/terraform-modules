locals {
  arn = var.create ? aws_iam_openid_connect_provider.this[0].arn : var.existing_provider_arn
}

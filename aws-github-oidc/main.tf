resource "aws_iam_openid_connect_provider" "this" {
  count           = var.create ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.thumbprints
}

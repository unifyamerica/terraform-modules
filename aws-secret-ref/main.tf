resource "aws_secretsmanager_secret" "this" {
  count                   = var.create ? 1 : 0
  name                    = var.name
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = 7
  tags                    = var.tags
}

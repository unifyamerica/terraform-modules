locals {
  arn = var.create ? aws_secretsmanager_secret.this[0].arn : var.existing_secret_arn
}

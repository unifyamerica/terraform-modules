locals {
  image_tag_sanitized = replace(lower(var.image_tag), "/[^a-z0-9-]/", "-")
}

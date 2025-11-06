variable "role_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "allowed_subjects" {
  type = list(string)
}

variable "tags" {
  type = map(string)
  default = {}
}

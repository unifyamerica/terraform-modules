variable "create" {
  type = bool
}

variable "existing_provider_arn" {
  type = string
  default = null
}

variable "thumbprints" {
  type    = list(string)
}

variable "create" {
  type = bool
  default = false
}

variable "name" {
  type = string
  default = null
}

variable "kms_key_arn" {
  type = string
  default = null
}

variable "existing_secret_arn" {
  type = string
  default = null
}

variable "tags" {
  type = map(string)
  default = {}
}

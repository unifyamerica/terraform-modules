variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "private_subnets" {
    type = list(string)
}

variable "vpc_id" {
    type = string
}

variable "environment" {
    type = string
}

variable "additional_security_group_ids" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "worker_count" {
    type = string
}

variable "region" {
    type = string
}

variable "controller_image_repo" {
    type = string
}

variable "map_users" {
    type = list(object({
        userarn  = string
        username = string
        groups   = list(string)
    }))
}

variable "tags" { 
    type = map(string)
}

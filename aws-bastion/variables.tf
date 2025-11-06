variable "environment" {
    description = "Environment name (e.g., dev, staging, prod)"
    type = string
}

variable "name" {
  description = "Name of the bastion host"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the bastion host will be deployed"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the bastion host via SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Adjust this to restrict SSH access as needed
}

variable "ami" {
  description = "AMI for the bastion host. Use an official Linux AMI for your region (e.g., Amazon Linux 2)."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for accessing the bastion host"
  type        = string
}

variable "bastion_subnet_index" {
  description = "Index of the public subnet to use for the bastion host"
  type        = number
  default     = 0
}

variable "additional_tags" {
  description = "Addditional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs in the VPC"
  type        = list(string)
}

variable "user_data" {
  description = "Optional cloud-init user_data script to be executed on instance launch"
  type        = string
  default     = ""  # Default to empty if not provided
}

output "vpc_id" {
  value = module.vpc.vpc_id
  description = "ID of the VPC"
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
  description = "List of IDs of the public subnets"
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
  description = "List of IDs of the private subnets"
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_ids[0] # Access the first private route table ID
  description = "ID of the private route table"
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_ids[0] # Access the first public route table ID
  description = "ID of the public route table"
}

output "nat_gateway_ids" {
  value = module.vpc.nat_ids
  description = "List of NAT Gateway IDs"
}

output "application_subnets" {
  value = slice(module.vpc.private_subnets, 0, length(module.vpc.private_subnets) / 2)
}

output "database_subnets" {
  value = slice(module.vpc.private_subnets, length(module.vpc.private_subnets) / 2, length(module.vpc.private_subnets))
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
  description = "ID of the default security group"
}

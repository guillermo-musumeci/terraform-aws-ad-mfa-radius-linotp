##############################
## Network Module - Outputs ##
##############################

output "network_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "network_azs" {
  description = "List of AZs"
  value       = module.vpc.azs
}

output "network_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "network_private_subnets_cidr_blocks" {
  description = "List of IDs of private subnets CIDR blocks"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "network_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "network_public_subnets_cidr_blocks" {
  description = "List of IDs of public subnets CIDR blocks"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "network_database_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.database_subnets
}

output "network_database_subnets_cidr_blocks" {
  description = "List of IDs of database subnets CIDR blocks"
  value       = module.vpc.database_subnets_cidr_blocks
}

output "network_vpc_cidr_block" {
  description = "CIDR Block"
  value       = module.vpc.vpc_cidr_block
}

output "network_database_subnet_group" {
  description = "Subnet group for database"
  value       = module.vpc.database_subnet_group
}

output "network_private_route_table_ids" {
  description = "Private route table ids"
  value       = module.vpc.private_route_table_ids
}


output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

# Routes
output "database_route_table" {
  description = "Database Route Table"
  value       = module.vpc.database_route_table_ids
}

output "private_route_table" {
  description = "Private Route Table"
  value       = module.vpc.private_route_table_ids
}

output "public_route_table" {
  description = "Public Route Table"
  value       = module.vpc.public_route_table_ids
}

# Security Groups

output "aws_security_group_default" {
  description = "Security Group ID DEFAULT"
  value       = module.vpc.default_security_group_id
}

output "aws_security_group_ssh" {
  description = "Security Group ID for SSH"
  value       = aws_security_group.allows_ssh.id
}

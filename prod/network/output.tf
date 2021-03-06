output "vpc_arn" {
  description = "The arn of the vpc"
  value       = module.vpc.vpc_arn
}
output "vpc_id" {
  description = "The id of the vpc"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The ids of the public subnet"
  value       = module.vpc.public_subnets
}
output "public_subnet_arns" {
  description = "The arns of the public subnet"
  value       = module.vpc.public_subnet_arns
}


output "private_subnet_ids" {
  description = "The ids of the private subnet"
  value       = module.vpc.private_subnets
}
output "private_subnet_arns" {
  description = "The arns of the private subnet"
  value       = module.vpc.private_subnet_arns
}

output "database_subnet_ids" {
  description = "The ids of the database subnet"
  value       = module.vpc.database_subnets
}
output "database_subnet_arns" {
  description = "The arns of the database subnet"
  value       = module.vpc.database_subnet_arns
}

output "igw_arn" {
  description = "The arn of the internet gateway"
  value       = module.vpc.igw_arn
}
output "igw_id" {
  description = "The id of the internet gateway"
  value       = module.vpc.igw_id
}


output "natgw_ids" {
  description = "The ids of the nat gateway"
  value       = module.vpc.natgw_ids
}
output "nat_public_ips" {
  description = "The public ip list of the nat gateway"
  value       = module.vpc.nat_public_ips
}


output "gateway_subnet_ids" {
  description = "The ids of gateway subnet"
  value       = values(aws_subnet.gateway_subnets)[*].id
}

output "gateway_rtb_id" {
  description = "The id of gateway rtb"
  value = aws_route_table.gateway_rtb.id
}

output "gateway_sg_id" {
  description = "THe id of gateway sg"
  value       = module.gateway_sg.security_group_id
}
output "gateway_sg_name" {
  description = "The name of gateway sg"
  value       = module.gateway_sg.security_group_name
}

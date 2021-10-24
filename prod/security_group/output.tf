output "management_sg_id" {
  description = "The id of management sg"
  value       = module.management_sg.security_group_id
}
output "management_sg_name" {
  description = "The name of management sg"
  value       = module.management_sg.security_group_name
}

output "public_elb_sg_id" {
  description = "The id of public elb sg"
  value       = module.public_elb_sg.security_group_id
}
output "public_elb_sg_name" {
  description = "The name of public elb sg"
  value       = module.public_elb_sg.security_group_name
}

output "frontend_app_sg_id" {
  description = "The id of frontend app sg"
  value       = module.frontend_app_sg.security_group_id
}
output "frontend_app_sg_name" {
  description = "The name of frontend app sg"
  value       = module.frontend_app_sg.security_group_name
}

output "internal_elb_sg_id" {
  description = "The id of internal elb sg"
  value       = module.internal_elb_sg.security_group_id
}
output "internal_elb_sg_name" {
  description = "The name of internal elb sg"
  value       = module.internal_elb_sg.security_group_name
}

output "backend_app_sg_id" {
  description = "The id of backend app sg"
  value       = module.backend_app_sg.security_group_id
}
output "backend_app_sg_name" {
  description = "The name of backend app sg"
  value       = module.backend_app_sg.security_group_name
}

output "rds_sg_id" {
  description = "The id of rds sg"
  value       = module.rds_sg.security_group_id
}
output "rds_sg_name" {
  description = "The name of rds sg"
  value       = module.rds_sg.security_group_name
}

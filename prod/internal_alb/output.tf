output "elb_arn" {
  description = "The arn of elb"
  value       = module.alb.lb_arn
}
output "elb_id" {
  description = "The id of elb"
  value       = module.alb.lb_id
}


output "target_group_arns" {
  description = "The arns of target group"
  value       = module.alb.target_group_arns
}
output "target_group_names" {
  description = "The name of target group"
  value       = module.alb.target_group_names
}

output "http_tcp_listener_arns" {
  description = "The arns of http listener"
  value       = module.alb.http_tcp_listener_arns
}
output "http_tcp_listener_ids" {
  description = "The ids of http listener"
  value       = module.alb.http_tcp_listener_ids
}

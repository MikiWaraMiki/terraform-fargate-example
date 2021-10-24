output "parameter_group_name" {
  value = aws_db_parameter_group.mysql.id
}

output "cluster_parameter_group_name" {
  value = aws_rds_cluster_parameter_group.mysql.name
}

output "rds_cluster_id" {
  value = module.aurora_mysql.rds_cluster_id
}
output "rds_cluster_resource_id" {
  value = module.aurora_mysql.rds_cluster_resource_id
}
output "rds_cluster_endpoint" {
  value = module.aurora_mysql.rds_cluster_endpoint
}
output "rds_reader_endpoint" {
  value = module.aurora_mysql.rds_cluster_reader_endpoint
}

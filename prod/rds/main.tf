data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = local.backend_config.bucket
    key    = "fargate_example/prod/network.tfstate"
    region = local.backend_config.region
  }
}

data "terraform_remote_state" "security_group" {
  backend = "s3"

  config = {
    bucket = local.backend_config.bucket
    key    = "fargate_example/prod/security_group.tfstate"
    region = local.backend_config.region
  }
}


resource "aws_rds_cluster_parameter_group" "mysql" {
  name        = "${var.environment}-aurora-mysql57"
  family      = "aurora-mysql5.7"
  description = "${var.environment}-aurora-mysql-57"
}

resource "aws_db_parameter_group" "mysql" {
  name        = "${var.environment}-aurora-mysql57"
  family      = "aurora-mysql5.7"
  description = "${var.environment}-aurora-mysql-57"
}

module "aurora_mysql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 5.0"

  name                  = "${var.environment}-aurora-mysql"
  engine                = "aurora-mysql"
  engine_version        = "5.7.12"
  instance_type         = "db.t3.small"
  instance_type_replica = "db.t3.small"

  replica_count = 1

  vpc_id                = data.terraform_remote_state.network.outputs.vpc_id
  create_security_group = false
  subnets               = data.terraform_remote_state.network.outputs.database_subnet_ids
  vpc_security_group_ids = [
    data.terraform_remote_state.security_group.outputs.rds_sg_id
  ]

  storage_encrypted = true
  apply_immediately = true

  username               = "admin"
  create_random_password = true

  database_name = "sbcntrapp"

  db_parameter_group_name         = aws_db_parameter_group.mysql.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql.id
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = local.backend_config.bucket
    key    = "fargate_example/prod/network.tfstate"
    region = local.backend_config.region
  }
}

module "management_sg" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id       = data.terraform_remote_state.network.outputs.vpc_id
  name         = "${var.pj_prefix}-${var.environment}-management-sg"
  description  = "Security Group of management"
  egress_rules = ["all-all"]

  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }
}

module "public_elb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  name        = "${var.pj_prefix}-${var.environment}-public-elb-sg"
  description = "Security group for ingress"
  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]


  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }
}

module "frontend_app_sg" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  name        = "${var.pj_prefix}-${var.environment}-frontend-sg"
  description = "Security Group of front container app"
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.public_elb_sg.security_group_id
      description              = "Allow HTTP Fromt Public ELB"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  egress_rules                                             = ["all-all"]


  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }

}

module "internal_elb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  name        = "${var.pj_prefix}-${var.environment}-internal-elb-sg"
  description = "Security Group of internal elb"
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.frontend_app_sg.security_group_id
      description              = "Allow HTTP from Frontend App"
    },
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.management_sg.security_group_id
      description              = "Allow HTTP from management."
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2
  egress_rules                                             = ["all-all"]


  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }

}

module "backend_app_sg" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  name        = "${var.pj_prefix}-${var.environment}-backend-sg"
  description = "Security group of backend container app"
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.internal_elb_sg.security_group_id
      description              = "Allow HTTP from internal ELB"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  egress_rules                                             = ["all-all"]


  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }

}

module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  name        = "${var.pj_prefix}-${var.environment}-rds-sg"
  description = "Security group of db"
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.backend_app_sg.security_group_id
      description              = "Allow Mysql from backend app."
    },
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.management_sg.security_group_id
      description              = "Allow mysql from management."
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2
  egress_rules                                             = ["all-all"]

  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }

}

module "gateway_sg" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id       = data.terraform_remote_state.network.outputs.vpc_id
  name         = "${var.pj_prefix}-${var.environment}-gateway-sg"
  description  = "Security Group of gateway endpoint"
  egress_rules = ["all-all"]

  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }
}

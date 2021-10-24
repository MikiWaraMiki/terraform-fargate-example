locals {
  gateway_subnets = {
    "1a" = "10.0.250.0/24",
    "1c" = "10.0.251.0/24"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.pj_prefix}-${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.240.0/24", "10.0.241.0/24"]
  private_subnets  = ["10.0.8.0/24", "10.0.9.0/24"]
  database_subnets = ["10.0.16.0/24", "10.0.17.0/24"]

  create_database_subnet_route_table = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_support     = true
  enable_dns_hostnames   = true

  tags = {
    Environment = var.environment
  }
}

// NOTE: GatewayEndpoint配置用のサブネット
resource "aws_subnet" "gateway_subnets" {
  for_each = local.gateway_subnets

  vpc_id            = module.vpc.vpc_id
  cidr_block        = each.value
  availability_zone = "ap-northeast-${each.key}"

  tags = {
    Environment = var.environment
    Name        = "${var.pj_prefix}-${var.environment}-gateway-subnet-${each.key}"
  }
}


resource "aws_route_table" "gateway_rtb" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Environment = var.environment
    Name        = "${var.pj_prefix}-${var.environment}-gateway-rtb"
  }
}

resource "aws_route_table_association" "gateway_rtb_associate" {
  for_each       = toset(values(aws_subnet.gateway_subnets)[*].id)
  route_table_id = aws_route_table.gateway_rtb.id
  subnet_id      = each.value
}

// Gateway Endpoint用のセキュリティグループのみここで管理する
module "gateway_sg" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id       = module.vpc.vpc_id
  name         = "${var.pj_prefix}-${var.environment}-gateway-sg"
  description  = "Security Group of gateway endpoint"
  egress_rules = ["all-all"]

  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }
}

module "gateway_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.gateway_sg.security_group_id]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      tags         = { Name = "${var.pj_prefix}-${var.environment}-s3" }
      route_table_ids = [
        aws_route_table.gateway_rtb.id
      ]
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = values(aws_subnet.gateway_subnets)[*].id
      tags                = { Name = "${var.pj_prefix}-${var.environment}-ecr-dkr" }
    }
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = values(aws_subnet.gateway_subnets)[*].id
      tags                = { Name : "${var.pj_prefix}-${var.environment}-ecr-api" }
    },
    cloudwatch = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = values(aws_subnet.gateway_subnets)[*].id
      tags                = { Name = "${var.pj_prefix}-${var.environment}-logs-api" }
    }
    secretes_manager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      subnet_ids          = values(aws_subnet.gateway_subnets)[*].id
      tags                = { Name = "${var.pj_prefix}-${var.environment}-secretsmanager" }
    }
  }

  tags = {
    Environment = var.environment
  }
}



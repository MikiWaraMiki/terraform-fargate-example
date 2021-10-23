module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.pj_prefix}-${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.240.0/24", "10.0.241.0/24"]
  private_subnets  = ["10.0.8.0/24", "10.0.9.0/24", "10.0.248.0/24", "10.0.249.0/24"]
  database_subnets = ["10.0.16.0/24", "10.0.17.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Environment = var.environment
  }
}

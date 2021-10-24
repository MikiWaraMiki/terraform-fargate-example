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

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name     = "${var.environment}-public-alb"
  internal = false

  load_balancer_type = "application"

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  subnets = [
    data.terraform_remote_state.network.outputs.public_subnet_ids[0],
    data.terraform_remote_state.network.outputs.public_subnet_ids[1]
  ]
  security_groups = [
    data.terraform_remote_state.security_group.outputs.public_elb_sg_id
  ]

  target_groups = [
    {
      name_prefix      = "front-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        enabled             = true
        path                = "/"
        port                = "traffic-port"
        interval            = 15
        healthy_threshold   = 3
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      tags = {
        Environment = var.environment
      }
    },
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]

  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }
}

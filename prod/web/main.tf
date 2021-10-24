data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = local.backend_config.bucket
    key    = "fargate_example/prod/ecr.tfstate"
    region = local.backend_config.region
  }
}


data "aws_iam_role" "execution_role" {
  name = "ecsTaskExecutionRole"
}

module "backend_log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 2.0"

  name              = "/ecs/go-backend"
  retention_in_days = 5 //days
}

module "frontend_log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 2.0"

  name              = "/ecs/react-frontend"
  retention_in_days = 5 //days

}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.environment}-fargate-backend"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  execution_role_arn = data.aws_iam_role.execution_role.arn

  container_definitions = jsonencode(
    [
      {
        "name" : "go-backend",
        "image" : "${data.terraform_remote_state.ecr.outputs.backend_repo_repository_url}:v1",
        "memoryReservation" : 512,
        "essential" : true,
        "portMappings" : [
          {
            "protocol" : "tcp",
            "containerPort" : 80,
            "hostPort" : 80
          }
        ],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-region" : "ap-northeast-1",
            "awslogs-stream-prefix" : "ecs",
            "awslogs-group" : "/ecs/go-backend"
          }
        }
      }
    ]
  )
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.environment}-fargate-frontend"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  execution_role_arn = data.aws_iam_role.execution_role.arn

  container_definitions = jsonencode(
    [
      {
        "name" : "react-frontend",
        "image" : "${data.terraform_remote_state.ecr.outputs.frontend_repo_repository_url}:v1",
        "memoryReservation" : 512,
        "essential" : true,
        "portMappings" : [
          {
            "protocol" : "tcp",
            "containerPort" : 80,
            "hostPort" : 80
          }
        ],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-region" : "ap-northeast-1",
            "awslogs-stream-prefix" : "ecs",
            "awslogs-group" : "/ecs/react-frontend"
          }
        }
      },

    ]
  )
}

module "cluster" {
  source = "terraform-aws-modules/ecs/aws"

  name               = "${var.environment}-cluster"
  container_insights = true

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1,
      base              = 1
    },
    {
      capacity_provider = "FARGATE_SPOT",
      weight            = 2
    }
  ]
}

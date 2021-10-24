data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = local.backend_config.bucket
    key    = "fargate_example/prod/ecr.tfstate"
    region = local.backend_config.region
  }
}

data "terraform_remote_state" "internal_alb" {
  backend = "s3"

  config = {
    bucket = local.backend_config.bucket
    key    = "fargate_example/prod/internal_alb.tfstate"
    region = local.backend_config.region
  }
}

locals {
  backend_host = "http://${data.terraform_remote_state.internal_alb.outputs.elb_dns}"
}


data "aws_iam_role" "execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_secretsmanager_secret" "dbcredentials" {
  name = "sbcntr/mysql"
}

data "aws_iam_policy_document" "access_secrets_manager" {
  statement {
    sid = "GetSecretForECS"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "access_secrets_manager" {
  name   = "${var.environment}-secrets-manager"
  policy = data.aws_iam_policy_document.access_secrets_manager.json
}

resource "aws_iam_role_policy_attachment" "access_secrets_manager" {
  role       = data.aws_iam_role.execution_role.id
  policy_arn = aws_iam_policy.access_secrets_manager.arn
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
        },
        "Secrets" : [
          {
            "Name" : "DB_HOST",
            "ValueFrom" : "${data.aws_secretsmanager_secret.dbcredentials.arn}:host::"
          },
          {
            "Name" : "DB_NAME",
            "ValueFrom" : "${data.aws_secretsmanager_secret.dbcredentials.arn}:dbname::"
          },
          {
            "Name" : "DB_USERNAME",
            "ValueFrom" : "${data.aws_secretsmanager_secret.dbcredentials.arn}:username::"
          },
          {
            "Name" : "DB_PASSWORD",
            "ValueFrom" : "${data.aws_secretsmanager_secret.dbcredentials.arn}:password::"
          }
        ]
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
        },
        "Environment" : [
          {
            "Name" : "APP_SERVICE_HOST",
            "Value" : local.backend_host
          },
          {
            "Name" : "NOTIF_SERVICE_HOST",
            "Value" : local.backend_host
          },
          {
            "Name" : "SESSION_SECRET_KEY",
            "Value" : "41b678c65b37bf99c37bcab522802760"
          }
        ]
        "Secrets" : [
          {
            "Name" : "DB_HOST",
            "ValueFrom" : "${data.aws_secretsmanager_secret.dbcredentials.arn}:host::"
          },
          {
            "Name" : "DB_NAME",
            "ValueFrom" : "${data.aws_secretsmanager_secret.dbcredentials.arn}:dbname::"
          },
          {
            "Name" : "DB_USERNAME",
            "ValueFrom" : "${data.aws_secretsmanager_secret.dbcredentials.arn}:username::"
          },
          {
            "Name" : "DB_PASSWORD",
            "ValueFrom" : "${data.aws_secretsmanager_secret.dbcredentials.arn}:password::"
          }
        ]
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

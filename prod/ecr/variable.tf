locals {
  backend_config = yamldecode(file("../backend-config.yml"))
}

variable "environment" {
  default = "prod"
}

variable "pj_prefix" {
  default = "fargate_sample"
}

locals {
  backend_config = yamldecode(file("${find_in_parent_folders("backend-config.yml")}"))
}

remote_state {
  backend = "s3"
  config = {
    bucket  = "${local.backend_config.bucket}"
    key     = "fargate_example/prod${path_relative_to_include()}.tfstate"
    region  = local.backend_config.region
    encrypt = local.backend_config.encrypt
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "ap-northeast-1"
}
EOF
}

generate "backend" {
  path      = "terraform.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">=1.0.0"
  backend "s3" {}
}
EOF
}

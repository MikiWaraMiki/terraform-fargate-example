data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = local.backend_config.bucket
    key    = "fargate_example/prod/ecr.tfstate"
    region = local.backend_config.region
  }
}

data "aws_iam_policy_document" "allow_ecr" {
  statement {
    sid    = "ListImagesInRepository"
    effect = "Allow"
    actions = [
      "ecr:ListImages"
    ]
    resources = [
      data.terraform_remote_state.ecr.outputs.backend_repo_arn,
      data.terraform_remote_state.ecr.outputs.frontend_repo_arn
    ]
  }
  statement {
    sid    = "GetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "ManageRepositoryContents"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = [
      data.terraform_remote_state.ecr.outputs.backend_repo_arn,
      data.terraform_remote_state.ecr.outputs.frontend_repo_arn
    ]
  }
}

resource "aws_iam_policy" "ecr_access_policy" {
  name   = "${var.pj_prefix}-${var.environment}-ecr-access"
  policy = data.aws_iam_policy_document.allow_ecr.json
  tags = {
    Environment = var.environment
  }
}

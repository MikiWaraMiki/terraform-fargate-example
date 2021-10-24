data "aws_iam_policy" "codedepoly_for_ecs" {
  name = "AWSCodeDeployRoleForECS"
}

data "aws_iam_policy_document" "codedeploy_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_codedeploy_role" {
  name               = "${var.environment}-ecs-codedeploy"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume.json
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.ecs_codedeploy_role.name
  policy_arn = data.aws_iam_policy.codedepoly_for_ecs.arn
}

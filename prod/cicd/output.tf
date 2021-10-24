output "codedeploy_role_name" {
  value = aws_iam_role.ecs_codedeploy_role.name
}

output "codedeploy_role_arn" {
  value = aws_iam_role.ecs_codedeploy_role.arn
}

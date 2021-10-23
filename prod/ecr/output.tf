output "backend_repo_arn" {
  description = "The arn of backend repository"
  value       = aws_ecr_repository.backend.arn
}
output "backend_repo_repository_url" {
  description = "The url of backend repo"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_repo_arn" {
  description = "The arn of frontend repository"
  value       = aws_ecr_repository.frontend.arn
}
output "frontend_repo_repository_url" {
  description = "The url of frontend repository"
  value       = aws_ecr_repository.frontend.repository_url
}

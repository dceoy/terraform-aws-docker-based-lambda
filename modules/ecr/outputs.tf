output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.container.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.container.name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.container.repository_url
}

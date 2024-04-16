output "ecr_repository_id" {
  description = "ECR repository ID"
  value       = aws_ecr_repository.container.registry_id
}

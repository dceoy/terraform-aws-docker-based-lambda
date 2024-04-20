resource "aws_ecr_repository" "container" {
  name                 = local.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
  tags = {
    Name       = local.ecr_repository_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_ecr_lifecycle_policy" "container" {
  repository = aws_ecr_repository.container.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the latest image"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete older images after 14 days"
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

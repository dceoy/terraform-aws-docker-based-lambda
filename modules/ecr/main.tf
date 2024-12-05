# trivy:ignore:avd-aws-0031
# trivy:ignore:avd-aws-0033
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
        description  = "Keep images with sematic versioning"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["*.*.*", "v*.*.*"]
          countType     = "imageCountMoreThan"
          countNumber   = var.ecr_lifecycle_policy_semver_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_lifecycle_policy_any_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Remove untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.ecr_lifecycle_policy_untagged_image_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

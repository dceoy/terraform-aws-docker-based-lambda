locals {
  ecr_repository_name = var.ecr_repository_name != null ? var.ecr_repository_name : "${var.system_name}-${var.env_type}-container"
}

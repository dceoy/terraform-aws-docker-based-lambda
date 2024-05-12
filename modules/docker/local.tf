locals {
  docker_image_name = var.docker_image_name != null ? var.docker_image_name : "${var.system_name}-${var.env_type}-lambda-function"
}

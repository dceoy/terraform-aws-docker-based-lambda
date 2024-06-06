resource "docker_image" "container" {
  name         = "${local.docker_image_name}:${local.docker_image_primary_tag}"
  force_remove = var.docker_image_force_remove
  keep_locally = var.docker_image_keep_locally
  build {
    context    = var.docker_image_build_context
    dockerfile = var.docker_image_build_dockerfile
    build_args = var.docker_image_build_build_args
    platform   = var.docker_image_build_platform
    target     = var.docker_image_build_target
    tag        = local.docker_image_secondary_tags
  }
  triggers = {
    docker_image_primary_tag = local.docker_image_primary_tag
  }
}

resource "docker_registry_image" "primary" {
  name          = docker_image.container.name
  keep_remotely = var.docker_registry_image_keep_remotely
  triggers = {
    image_id = docker_image.container.image_id
  }
}

resource "docker_registry_image" "secondary" {
  for_each = {
    for t in local.docker_image_secondary_tags : t => t
  }
  name          = each.key
  keep_remotely = var.docker_registry_image_keep_remotely
  triggers = {
    image_id = docker_image.container.image_id
  }
}

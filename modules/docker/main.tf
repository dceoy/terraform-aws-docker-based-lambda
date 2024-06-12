resource "docker_image" "container" {
  name         = "${local.docker_image_name}:${local.docker_image_primary_tag}"
  force_remove = var.docker_image_force_remove
  keep_locally = true
  dynamic "build" {
    for_each = var.docker_image_build ? [true] : []
    content {
      context    = var.docker_image_build_context
      dockerfile = var.docker_image_build_dockerfile
      build_args = var.docker_image_build_build_args
      platform   = var.docker_image_build_platform
      target     = var.docker_image_build_target
    }
  }
  triggers = {
    docker_image_primary_tag = local.docker_image_primary_tag
  }
}

resource "docker_tag" "container" {
  for_each     = toset(local.docker_image_secondary_tags)
  source_image = docker_image.container.name
  target_image = each.key
}

resource "docker_registry_image" "primary" {
  name          = docker_image.container.name
  keep_remotely = true
  triggers = {
    image_id = docker_image.container.image_id
  }
}

resource "docker_registry_image" "secondary" {
  depends_on = [docker_registry_image.primary, docker_tag.container]
  for_each = {
    for t in local.docker_image_secondary_tags : t => t
  }
  name          = each.key
  keep_remotely = true
  triggers = {
    image_id = docker_image.container.image_id
  }
}

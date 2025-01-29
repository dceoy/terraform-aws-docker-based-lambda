resource "docker_image" "primary" {
  name         = local.docker_image_primary_name
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
    image_name = local.docker_image_primary_name
  }
}

resource "docker_tag" "secondary" {
  for_each     = toset(local.docker_image_secondary_names)
  source_image = docker_image.primary.name
  target_image = each.key
}

resource "docker_registry_image" "primary" {
  depends_on    = [docker_image.primary, docker_tag.secondary]
  name          = docker_image.primary.name
  keep_remotely = true
  triggers = {
    image_id = docker_image.primary.image_id
  }
}

resource "docker_registry_image" "secondary" {
  depends_on    = [docker_tag.secondary, docker_registry_image.primary]
  for_each      = docker_tag.secondary
  name          = each.key
  keep_remotely = true
  triggers = {
    primary_registry_image_id = docker_registry_image.primary.id
  }
}

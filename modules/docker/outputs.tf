output "docker_registry_image_uri" {
  description = "Docker registry image URI"
  value       = docker_registry_image.container.name
}

output "docker_registry_image_id" {
  description = "Docker registry image ID"
  value       = docker_registry_image.container.id
}

output "docker_registry_image_uri" {
  description = "Docker registry image URI"
  value       = docker_registry_image.primary.name
}

output "docker_registry_image_id" {
  description = "Docker registry image ID"
  value       = docker_registry_image.primary.id
}

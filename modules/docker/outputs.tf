output "docker_registry_primary_image_uri" {
  description = "Docker registry primary image URI"
  value       = docker_registry_image.primary.name
}

output "docker_registry_primary_image_id" {
  description = "Docker registry primary image ID"
  value       = docker_registry_image.primary.id
}

output "docker_registry_secondary_image_uris" {
  description = "Docker registry secondary image URIs"
  value       = values(docker_registry_image.secondary)[*].name
}

output "docker_registry_secondary_image_ids" {
  description = "Docker registry secondary image IDs"
  value       = values(docker_registry_image.secondary)[*].id
}

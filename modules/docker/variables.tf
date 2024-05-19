variable "system_name" {
  description = "System name"
  type        = string
  default     = "dbl"
}

variable "env_type" {
  description = "Environment type"
  type        = string
  default     = "dev"
}

variable "ecr_repository_url" {
  description = "ECR repository URL"
  type        = string
  default     = null
}

variable "ecr_image_secondary_tags" {
  description = "ECR image secondary tags"
  type        = list(string)
  default     = []
}

variable "docker_image_force_remove" {
  description = "Remove the image forcibly when the resource is destroyed"
  type        = bool
  default     = false
}

variable "docker_image_keep_locally" {
  description = "Keep the local image on destroy operation"
  type        = bool
  default     = false
}

variable "docker_image_build_context" {
  description = "Docker image build context"
  type        = string
  default     = "."
}

variable "docker_image_build_dockerfile" {
  description = "Dockerfile name"
  type        = string
  default     = "Dockerfile"
}

variable "docker_image_build_build_args" {
  description = "Docker image build-time variables"
  type        = map(string)
  default     = {}
}

variable "docker_image_build_platform" {
  description = "Docker image platform"
  type        = string
  default     = null
}

variable "docker_image_build_target" {
  description = "Docker image build target stage"
  type        = string
  default     = null
}

variable "docker_image_build_trigger_file_patterns" {
  description = "Patterns to match files that will trigger a build"
  type        = list(string)
  default     = ["**"]
}

variable "docker_registry_image_keep_remotely" {
  description = "Keep the remote image on destroy operation"
  type        = bool
  default     = false
}

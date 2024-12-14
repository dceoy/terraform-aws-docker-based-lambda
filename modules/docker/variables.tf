variable "system_name" {
  description = "System name"
  type        = string
  default     = "slc"
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
  description = "Whether to remove the image forcibly when the resource is destroyed"
  type        = bool
  default     = false
}

variable "docker_image_build" {
  description = "Whether to build the Docker image"
  type        = bool
  default     = true
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

variable "docker_image_primary_tag" {
  description = "Docker image primary tag"
  type        = string
  default     = "latest"
}

variable "docker_host" {
  description = "Docker daemon address"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

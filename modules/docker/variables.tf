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

variable "docker_image_name" {
  description = "Docker image name"
  type        = string
  default     = null
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = null
}

variable "docker_image_force_remove" {
  description = "Docker image force remove"
  type        = bool
  default     = false
}

variable "docker_image_keep_locally" {
  description = "Docker image keep locally"
  type        = bool
  default     = false
}

variable "docker_image_build_context" {
  description = "Docker image build context"
  type        = string
  default     = "."
}

variable "docker_image_build_dockerfile" {
  description = "Docker image build dockerfile"
  type        = string
  default     = "Dockerfile"
}

variable "docker_image_build_build_args" {
  description = "Docker image build build args"
  type        = map(string)
  default     = {}
}

variable "docker_image_build_platform" {
  description = "Docker image build platform"
  type        = string
  default     = null
}

variable "docker_image_build_trigger_file_patterns" {
  description = "Docker image build trigger file patterns"
  type        = list(string)
  default     = ["**"]
}

variable "docker_registry_image_keep_remotely" {
  description = "Docker registry image keep remotely"
  type        = bool
  default     = false
}

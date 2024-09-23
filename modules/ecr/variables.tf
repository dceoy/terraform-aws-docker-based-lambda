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

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = null
}

variable "ecr_image_tag_mutability" {
  description = "ECR image tag mutability"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_force_delete" {
  description = "Whether to delete the ECR repository and all images in it"
  type        = bool
  default     = true
}

variable "ecr_lifecycle_policy_image_count" {
  description = "ECR lifecycle policy image count"
  type        = number
  default     = 1
}

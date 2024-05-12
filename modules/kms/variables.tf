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

variable "create_kms_key" {
  description = "Create a KMS key"
  type        = bool
  default     = true
}

variable "kms_key_deletion_window_in_days" {
  description = "The duration in days after which the key is deleted after destruction of the resource"
  type        = number
  default     = 30
  validation {
    condition     = var.kms_key_deletion_window_in_days >= 7 && var.kms_key_deletion_window_in_days <= 30
    error_message = "The deletion window must be between 7 and 30 days"
  }
}

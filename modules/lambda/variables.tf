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

variable "cloudwatch_logs_retention_in_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 14
  validation {
    condition     = var.cloudwatch_logs_retention_in_days >= 1 && var.cloudwatch_logs_retention_in_days <= 3653
    error_message = "CloudWatch Logs retention in days must be between 1 and 3653"
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  # default     = null
}

variable "s3_iam_policy_arn" {
  description = "S3 IAM policy ARN"
  type        = string
  # default     = null
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  # default     = null
}

variable "lambda_image_uri" {
  description = "Lambda image ID"
  type        = string
  default     = null
}

variable "lambda_architecture" {
  description = "Lambda architecture"
  type        = string
  default     = null
  validation {
    condition     = var.lambda_architecture == null || var.lambda_architecture == "x86_64" || var.lambda_architecture == "arm64"
    error_message = "Lambda architecture must be either x86_64 or arm64"
  }
}

variable "lambda_memory_size" {
  description = "Lambda memory size"
  type        = number
  default     = 128
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory size must be between 128 and 10240"
  }
}

variable "lambda_timeout" {
  description = "Lambda timeout"
  type        = number
  default     = 3
}

variable "lambda_reserved_concurrent_executions" {
  description = "Lambda reserved concurrent executions"
  type        = number
  default     = -1
  validation {
    condition     = var.lambda_reserved_concurrent_executions == -1 || var.lambda_reserved_concurrent_executions >= 0
    error_message = "Lambda reserved concurrent executions must be -1 or greater"
  }
}

variable "lambda_logging_config_log_format" {
  description = "Lambda logging config log format"
  type        = string
  default     = "Text"
  validation {
    condition     = var.lambda_logging_config_log_format == "Text" || var.lambda_logging_config_log_format == "JSON"
    error_message = "Lambda logging config log format must be either Text or JSON"
  }
}

variable "lambda_logging_config_application_log_level" {
  description = "Lambda logging config application log level"
  type        = string
  default     = "INFO"
  validation {
    condition     = var.lambda_logging_config_application_log_level == "TRACE" || var.lambda_logging_config_application_log_level == "DEBUG" || var.lambda_logging_config_application_log_level == "INFO" || var.lambda_logging_config_application_log_level == "WARN" || var.lambda_logging_config_application_log_level == "ERROR" || var.lambda_logging_config_application_log_level == "FATAL"
    error_message = "Lambda logging config application log level must be either TRACE, DEBUG, INFO, WARN, ERROR, or FATAL"
  }
}

variable "lambda_logging_config_system_log_level" {
  description = "Lambda logging config system log level"
  type        = string
  default     = "INFO"
  validation {
    condition     = var.lambda_logging_config_system_log_level == "DEBUG" || var.lambda_logging_config_system_log_level == "INFO" || var.lambda_logging_config_system_log_level == "WARN"
    error_message = "Lambda logging config system log level must be either DEBUG, INFO, or WARN"
  }
}

variable "lambda_ephemeral_storage_size" {
  description = "Lambda ephemeral storage size"
  type        = number
  default     = 512
  validation {
    condition     = var.lambda_ephemeral_storage_size >= 512 && var.lambda_ephemeral_storage_size <= 10240
    error_message = "Lambda ephemeral storage size must be between 512 and 10240"
  }
}

variable "lambda_image_config_entry_point" {
  description = "Lambda image config entry point"
  type        = list(string)
  default     = []

}
variable "lambda_image_config_command" {
  description = "Lambda image config command"
  type        = list(string)
  default     = []
}

variable "lambda_image_config_working_directory" {
  description = "Lambda image config working directory"
  type        = string
  default     = null
}

variable "lambda_environment_variables" {
  description = "Lambda environment variables"
  type        = map(string)
  default     = {}
}

variable "lambda_tracing_config_mode" {
  description = "Lambda tracing config mode"
  type        = string
  default     = "Active"
  validation {
    condition     = var.lambda_tracing_config_mode == "PassThrough" || var.lambda_tracing_config_mode == "Active"
    error_message = "Lambda tracing config mode must be either PassThrough or Active"
  }
}

variable "lambda_provisioned_concurrent_executions" {
  description = "Lambda provisioned concurrent executions"
  type        = number
  default     = -1
  validation {
    condition     = var.lambda_provisioned_concurrent_executions == -1 || var.lambda_provisioned_concurrent_executions >= 0
    error_message = "Lambda provisioned concurrent executions must be -1 or greater"
  }
}

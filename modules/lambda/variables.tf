variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "cloudwatch_logs_retention_in_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 30
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_logs_retention_in_days)
    error_message = "CloudWatch Logs retention in days must be 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 or 0 (zero indicates never expire logs)"
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "s3_iam_policy_arn" {
  description = "S3 IAM policy ARN"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any IAM policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "create_lambda_client_iam_role" {
  description = "Whether to create an IAM role for the Lambda function"
  type        = bool
  default     = false
}

variable "lambda_client_iam_role_managed_policy_arns" {
  description = "IAM role managed policy ARNs for the Lambda client IAM role"
  type        = list(string)
  default     = []
}

variable "lambda_client_iam_role_max_session_duration" {
  description = "IAM role maximum session duration for the Lambda client IAM role"
  type        = number
  default     = 3600
  validation {
    condition     = var.lambda_client_iam_role_max_session_duration >= 3600 && var.lambda_client_iam_role_max_session_duration <= 43200
    error_message = "IAM role maximum session duration must be between 3600 and 43200"
  }
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = null
}

variable "lambda_image_uri" {
  description = "Lambda image ID"
  type        = string
  default     = null
}

variable "lambda_architectures" {
  description = "Lambda instruction set architectures"
  type        = list(string)
  default     = ["x86_64"]
  validation {
    condition     = alltrue([for a in var.lambda_architectures : contains(["x86_64", "arm64"], a)])
    error_message = "Lambda architectures must be x86_64 or arm64"
  }
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
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
  description = "Lambda ephemeral storage (/tmp) size in MB"
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

variable "lambda_vpc_config_subnet_ids" {
  description = "List of subnet IDs associated with the Lambda function within the VPC"
  type        = list(string)
  default     = []
}

variable "lambda_vpc_config_security_group_ids" {
  description = "List of security group IDs associated with the Lambda function within the VPC"
  type        = list(string)
  default     = []
}

variable "lambda_vpc_config_ipv6_allowed_for_dual_stack" {
  description = "Whether to allow outbound IPv6 traffic on VPC Lambda functions that are connected to dual-stack subnets"
  type        = bool
  default     = false
}

variable "lambda_alias_name" {
  description = "Alias name for the Lambda function"
  type        = string
  default     = null
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

variable "lambda_maximum_event_age_in_seconds" {
  description = "Lambda maximum event age in seconds"
  type        = number
  default     = 21600
  validation {
    condition     = var.lambda_maximum_event_age_in_seconds >= 60 && var.lambda_maximum_event_age_in_seconds <= 21600
    error_message = "Lambda maximum event age in seconds must be between 60 and 21600"
  }
}

variable "lambda_maximum_retry_attempts" {
  description = "Lambda maximum retry attempts"
  type        = number
  default     = 2
  validation {
    condition     = var.lambda_maximum_retry_attempts >= 0 && var.lambda_maximum_retry_attempts <= 2
    error_message = "Lambda maximum retry attempts must be between 0 and 2"
  }
}

variable "lambda_dead_letter_sqs_queue_arn" {
  description = "SQS queue ARN to use as the dead-letter queue for the Lambda function"
  type        = string
  default     = null
}

variable "lambda_on_success_sqs_queue_arn" {
  description = "SQS queue ARN to use as the destination for successful asynchronous invocations"
  type        = string
  default     = null
}

variable "lambda_on_failure_sqs_queue_arn" {
  description = "SQS queue ARN to use as the destination for failed asynchronous invocations"
  type        = string
  default     = null
}

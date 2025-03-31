variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "lambda_function_arn" {
  description = "Lambda function ARN to be scheduled"
  type        = string
}

variable "lambda_permission_principal_org_id" {
  description = "Organization ID for the Lambda permission principal"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any IAM policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "enable_scheduler_schedule" {
  description = "Whether to enable the EventBridge Scheduler schedule"
  type        = bool
  default     = true
}

variable "scheduler_schedule_expression" {
  description = "When to run the schedule of EventBridge Scheduler (e.g., rate(1 hours))"
  type        = string
  default     = "rate(1 days)"
}

variable "scheduler_schedule_expression_timezone" {
  description = "Timezone in which the scheduling expression is evaluated for the EventBridge Scheduler schedule"
  type        = string
  default     = "UTC"
}

variable "scheduler_flexible_time_window_max_window_in_minutes" {
  description = "Maximum time window during which the EventBridge Scheduler schedule can be invoked"
  type        = number
  default     = 0
  validation {
    condition     = var.scheduler_flexible_time_window_max_window_in_minutes >= 0 && var.scheduler_flexible_time_window_max_window_in_minutes <= 1440
    error_message = "Maximum window in minutes must be between 0 and 1440"
  }
}

variable "scheduler_start_date" {
  description = "Date in UTC after which the EventBridge Scheduler schedule can begin invoking its target"
  type        = string
  default     = null
}

variable "scheduler_end_date" {
  description = "Date in UTC before which the EventBridge Scheduler schedule can invoke its target"
  type        = string
  default     = null
}

variable "scheduler_target_input" {
  description = "Text or well-formed JSON passed to the target of the EventBridge Scheduler schedule"
  type        = string
  default     = null
}

variable "scheduler_dead_letter_sqs_queue_arn" {
  description = "SQS queue ARN as the destination for the dead-letter queue of the EventBridge Scheduler schedule"
  type        = string
  default     = null
}

variable "scheduler_target_retry_policy_maximum_event_age_in_seconds" {
  description = "Maximum amount of time in seconds to continue to make retry attempts for the EventBridge Scheduler schedule"
  type        = number
  default     = 86400
  validation {
    condition     = var.scheduler_target_retry_policy_maximum_event_age_in_seconds >= 60 && var.scheduler_target_retry_policy_maximum_event_age_in_seconds <= 86400
    error_message = "Maximum event age in seconds must be between 60 and 86400"
  }
}

variable "scheduler_target_retry_policy_maximum_retry_attempts" {
  description = "Maximum number of retry attempts to make before the request fails for the EventBridge Scheduler schedule"
  type        = number
  default     = 185
  validation {
    condition     = var.scheduler_target_retry_policy_maximum_retry_attempts >= 0 && var.scheduler_target_retry_policy_maximum_retry_attempts <= 185
    error_message = "Maximum retry attempts must be between 0 and 185"
  }
}

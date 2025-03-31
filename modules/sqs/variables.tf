variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "create_sqs_queues" {
  description = "Whether to create SQS queues"
  type        = bool
  default     = true
}

variable "sqs_visibility_timeout_seconds" {
  description = "SQS visibility timeout in seconds"
  type        = number
  default     = 30
  validation {
    condition     = var.sqs_visibility_timeout_seconds >= 0 && var.sqs_visibility_timeout_seconds <= 43200
    error_message = "SQS visibility timeout in seconds must be between 0 and 43200"
  }
}

variable "sqs_message_retention_seconds" {
  description = "SQS message retention in seconds"
  type        = number
  default     = 345600
  validation {
    condition     = var.sqs_message_retention_seconds >= 60 && var.sqs_message_retention_seconds <= 1209600
    error_message = "SQS message retention in seconds must be between 60 and 1209600"
  }
}

variable "sqs_max_message_size" {
  description = "SQS maximum message size in bytes"
  type        = number
  default     = 262144
  validation {
    condition     = var.sqs_max_message_size >= 1024 && var.sqs_max_message_size <= 262144
    error_message = "SQS maximum message size must be between 1024 and 262144"
  }
}

variable "sqs_delay_seconds" {
  description = "SQS message delay in seconds"
  type        = number
  default     = 0
  validation {
    condition     = var.sqs_delay_seconds >= 0 && var.sqs_delay_seconds <= 900
    error_message = "SQS message delay in seconds must be between 0 and 900"
  }
}

variable "sqs_receive_wait_time_seconds" {
  description = "SQS receive wait time in seconds (long polling)"
  type        = number
  default     = 0
  validation {
    condition     = var.sqs_receive_wait_time_seconds >= 0 && var.sqs_receive_wait_time_seconds <= 20
    error_message = "SQS receive wait time in seconds must be between 0 and 20"
  }
}

variable "sqs_redrive_policy_max_receive_count" {
  description = "SQS redrive policy max receive count"
  type        = number
  default     = 10
  validation {
    condition     = var.sqs_redrive_policy_max_receive_count >= 1 && var.sqs_redrive_policy_max_receive_count <= 1000
    error_message = "SQS redrive policy max receive count must be between 1 and 1000"
  }
}

variable "sqs_fifo_queue" {
  description = "Whether to designate a FIFO queue"
  type        = bool
  default     = false
}

variable "sqs_content_based_deduplication" {
  description = "Whether to enable content-based deduplication"
  type        = bool
  default     = false
}

variable "sqs_deduplication_scope" {
  description = "SQS message deduplication scope"
  type        = string
  default     = "Queue"
  validation {
    condition     = var.sqs_deduplication_scope == "Queue" || var.sqs_deduplication_scope == "MessageGroup"
    error_message = "SQS deduplication scope must be either Queue or MessageGroup"
  }
}

variable "sqs_fifo_throughput_limit" {
  description = "FIFO queue throughput limit"
  type        = string
  default     = "perMessageGroupId"
  validation {
    condition     = var.sqs_fifo_throughput_limit == "perQueue" || var.sqs_fifo_throughput_limit == "perMessageGroupId"
    error_message = "FIFO queue throughput limit must be either perQueue or perMessageGroupId"
  }
}

variable "sqs_kms_data_key_reuse_period_seconds" {
  description = "SQS KMS data key reuse period in seconds"
  type        = number
  default     = 300
  validation {
    condition     = var.sqs_kms_data_key_reuse_period_seconds >= 60 && var.sqs_kms_data_key_reuse_period_seconds <= 86400
    error_message = "SQS KMS data key reuse period in seconds must be between 60 and 86400"
  }
}

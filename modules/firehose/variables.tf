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

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any IAM policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch Logs log group and Firehose stream"
  type        = string
  default     = null
}

variable "source_cloudwatch_logs_log_group_names" {
  description = "Subscribed CloudWatch Logs log group names (key: key name, value: log group name)"
  type        = map(string)
  default     = {}
}

variable "source_cloudwatch_logs_kms_key_arns" {
  description = "KMS key ARNs for subscribed CloudWatch Logs log groups (key: key name, value: KMS key ARN)"
  type        = map(string)
  default     = null
}

variable "destination_s3_bucket_id" {
  description = "Destination S3 bucket ID"
  type        = string
  default     = null
}

variable "destination_s3_kms_key_arn" {
  description = "KMS key ARN for the destination S3 bucket"
  type        = string
  default     = null
}

variable "firehose_extended_s3_configuration_buffering_size" {
  description = "Stream buffer size in MB for Firehose extended S3 configuration"
  type        = number
  default     = 5
  validation {
    condition     = var.firehose_extended_s3_configuration_buffering_size >= 1 && var.firehose_extended_s3_configuration_buffering_size <= 128
    error_message = "Firehose stream buffer size must be between 1 and 128"
  }
}

variable "firehose_extended_s3_configuration_buffering_interval" {
  description = "Stream buffer interval in seconds for Firehose extended S3 configuration"
  type        = number
  default     = 300
  validation {
    condition     = var.firehose_extended_s3_configuration_buffering_interval >= 0 && var.firehose_extended_s3_configuration_buffering_interval <= 900
    error_message = "Firehose stream buffer interval must be between 0 and 900"
  }
}

variable "firehose_extended_s3_configuration_compression_format" {
  description = "Stream compression format for Firehose extended S3 configuration"
  type        = string
  default     = "GZIP"
  validation {
    condition     = var.firehose_extended_s3_configuration_compression_format == "UNCOMPRESSED" || var.firehose_extended_s3_configuration_compression_format == "GZIP" || var.firehose_extended_s3_configuration_compression_format == "Snappy" || var.firehose_extended_s3_configuration_compression_format == "HADOOP_SNAPPY"
    error_message = "Firehose stream compression format must be UNCOMPRESSED, GZIP, Snappy, or HADOOP_SNAPPY"
  }
}

variable "firehose_extended_s3_configuration_custom_time_zone" {
  description = "Stream custom time zone for Firehose extended S3 configuration"
  type        = string
  default     = "UTC"
}

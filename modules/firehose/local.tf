locals {
  source_cloudwatch_logs_log_group_names = var.destination_s3_bucket_id != null ? var.source_cloudwatch_logs_log_group_names : {}
}

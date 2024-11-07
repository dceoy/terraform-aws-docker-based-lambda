output "firehose_stream_names" {
  description = "Firehose stream names"
  value       = { for k, v in aws_kinesis_firehose_delivery_stream.logs : k => v.name }
}

output "firehose_stream_iam_role_arn" {
  description = "Firehose stream IAM role ARN"
  value       = length(aws_iam_role.firehose) > 0 ? aws_iam_role.firehose[0].arn : null
}

output "firehose_cloudwatch_log_group_name" {
  description = "Firehose CloudWatch Logs log group name"
  value       = length(aws_cloudwatch_log_group.firehose) > 0 ? aws_cloudwatch_log_group.firehose[0].name : null
}

output "firehose_cloudwatch_log_stream_names" {
  description = "Firehose CloudWatch Log Stream names"
  value       = { for k, v in aws_cloudwatch_log_stream.firehose : k => v.name }
}

output "firehose_log_subscription_filter_names" {
  description = "Firehose CloudWatch Log Subscription Filter names"
  value       = { for k, v in aws_cloudwatch_log_subscription_filter.logs : k => v.name }
}

output "firehose_log_subscription_filter_iam_role_arn" {
  description = "Firehose CloudWatch Log Subscription Filter IAM role ARN"
  value       = length(aws_iam_role.logs) > 0 ? aws_iam_role.logs[0].arn : null
}

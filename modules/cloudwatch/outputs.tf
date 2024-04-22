output "cloudwatch_logs_log_group_name" {
  description = "CloudWatch Logs log group name"
  value       = aws_cloudwatch_log_group.lambda.arn
}

output "cloudwatch_logs_iam_policy_arn" {
  description = "CloudWatch Logs IAM policy ARN"
  value       = aws_iam_policy.logs.arn
}

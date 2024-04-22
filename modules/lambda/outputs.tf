output "lambda_function_arn" {
  description = "Lambda Function ARN"
  value       = aws_lambda_function.function.arn
}

output "lambda_function_qualified_arn" {
  description = "Lambda Function qualified ARN"
  value       = aws_lambda_function.function.qualified_arn
}

output "lambda_function_version" {
  description = "Lambda function version"
  value       = aws_lambda_function.function.version
}

output "lambda_execution_iam_role_arn" {
  description = "Lambda execution IAM role ARN"
  value       = aws_iam_role.function.arn
}

output "lambda_cloudwatch_logs_log_group_name" {
  description = "Lambda CloudWatch Logs log group name"
  value       = aws_cloudwatch_log_group.function.name
}

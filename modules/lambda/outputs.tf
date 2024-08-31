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

output "sqs_dead_letter_queue_arn" {
  description = "SQS dead-letter SQS queue ARN"
  value       = length(aws_sqs_queue.sqs_dead_letter) > 0 ? aws_sqs_queue.sqs_dead_letter[0].arn : null
}

output "sqs_dead_letter_queue_url" {
  description = "SQS dead-letter SQS queue URL"
  value       = length(aws_sqs_queue.sqs_dead_letter) > 0 ? aws_sqs_queue.sqs_dead_letter[0].url : null
}

output "lambda_dead_letter_sqs_queue_arn" {
  description = "Lambda dead-letter SQS queue ARN"
  value       = length(aws_sqs_queue.lambda_dead_letter) > 0 ? aws_sqs_queue.lambda_dead_letter[0].arn : null
}

output "lambda_dead_letter_sqs_queue_url" {
  description = "Lambda dead-letter SQS queue URL"
  value       = length(aws_sqs_queue.lambda_dead_letter) > 0 ? aws_sqs_queue.lambda_dead_letter[0].url : null
}

output "lambda_on_success_sqs_queue_arn" {
  description = "Lambda on-success SQS queue ARN"
  value       = length(aws_sqs_queue.lambda_on_success) > 0 ? aws_sqs_queue.lambda_on_success[0].arn : null
}

output "lambda_on_success_sqs_queue_url" {
  description = "Lambda on-success SQS queue URL"
  value       = length(aws_sqs_queue.lambda_on_success) > 0 ? aws_sqs_queue.lambda_on_success[0].url : null
}

output "lambda_on_failure_sqs_queue_arn" {
  description = "Lambda on-failure SQS queue ARN"
  value       = length(aws_sqs_queue.lambda_on_failure) > 0 ? aws_sqs_queue.lambda_on_failure[0].arn : null
}

output "lambda_on_failure_sqs_queue_url" {
  description = "Lambda on-failure SQS queue URL"
  value       = length(aws_sqs_queue.lambda_on_failure) > 0 ? aws_sqs_queue.lambda_on_failure[0].url : null
}

output "lambda_client_iam_role_arn" {
  description = "Lambda client IAM role ARN"
  value       = length(aws_iam_role.client) > 0 ? aws_iam_role.client[0].arn : null
}

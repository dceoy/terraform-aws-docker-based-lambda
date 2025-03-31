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

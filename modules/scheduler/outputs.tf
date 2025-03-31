output "scheduler_group_name" {
  description = "EventBridge Scheduler schedule group name"
  value       = aws_scheduler_schedule_group.lambda.name
}

output "scheduler_schedule_name" {
  description = "EventBridge Scheduler schedule name"
  value       = aws_scheduler_schedule.lambda.name
}

output "scheduler_iam_role_arn" {
  description = "EventBridge Scheduler IAM Role ARN"
  value       = aws_iam_role.scheduler.arn
}

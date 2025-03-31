resource "aws_lambda_permission" "eventbridge" {
  function_name       = local.lambda_function_name
  statement_id_prefix = "${local.lambda_function_name}-"
  action              = "lambda:InvokeFunction"
  principal           = "scheduler.amazonaws.com"
  principal_org_id    = var.lambda_permission_principal_org_id
  source_arn          = aws_scheduler_schedule.lambda.arn
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_scheduler_schedule_group" "lambda" {
  name = "${var.system_name}-${var.env_type}-lambda-eventbridge-scheduler-schedule-group"
  tags = {
    Name       = "${var.system_name}-${var.env_type}-lambda-eventbridge-scheduler-schedule-group"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_scheduler_schedule" "lambda" {
  name                         = "${var.system_name}-${var.env_type}-lambda-eventbridge-scheduler-schedule"
  group_name                   = aws_scheduler_schedule_group.lambda.name
  description                  = "EventBridge Scheduler Schedule for ${local.lambda_function_name}"
  kms_key_arn                  = var.kms_key_arn
  state                        = var.enable_scheduler_schedule ? "ENABLED" : "DISABLED"
  start_date                   = var.scheduler_start_date
  end_date                     = var.scheduler_end_date
  schedule_expression          = var.scheduler_schedule_expression
  schedule_expression_timezone = var.scheduler_schedule_expression_timezone
  flexible_time_window {
    mode                      = var.scheduler_flexible_time_window_max_window_in_minutes > 0 ? "FLEXIBLE" : "OFF"
    maximum_window_in_minutes = var.scheduler_flexible_time_window_max_window_in_minutes > 0 ? var.scheduler_flexible_time_window_max_window_in_minutes : null
  }
  target {
    arn      = var.lambda_function_arn
    role_arn = aws_iam_role.scheduler.arn
    input    = var.scheduler_target_input
    dynamic "dead_letter_config" {
      for_each = var.scheduler_dead_letter_sqs_queue_arn != null ? [true] : []
      content {
        arn = var.scheduler_dead_letter_sqs_queue_arn
      }
    }
    dynamic "retry_policy" {
      for_each = var.scheduler_target_retry_policy_maximum_retry_attempts > 0 ? [true] : []
      content {
        maximum_event_age_in_seconds = var.scheduler_target_retry_policy_maximum_event_age_in_seconds
        maximum_retry_attempts       = var.scheduler_target_retry_policy_maximum_retry_attempts
      }
    }
  }
}

resource "aws_iam_role" "scheduler" {
  name                  = "${var.system_name}-${var.env_type}-eventbridge-scheduler-iam-role"
  description           = "EventBridge Scheduler IAM Role for Lambda"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaServiceToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-eventbridge-scheduler-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.system_name}-${var.env_type}-eventbridge-scheduler-lambda-iam-policy"
  role = aws_iam_role.scheduler.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid      = "AllowLambdaInvokeFunction"
          Effect   = "Allow"
          Action   = ["lambda:InvokeFunction"]
          Resource = ["arn:aws:lambda:${local.region}:${local.account_id}:function:*"]
          Condition = {
            StringEquals = {
              "aws:ResourceTag/SystemName" = var.system_name
              "aws:ResourceTag/EnvType"    = var.env_type
            }
          }
        }
      ],
      (
        var.kms_key_arn != null ? [
          {
            Sid      = "AllowKMSDecrypt"
            Effect   = "Allow"
            Action   = ["kms:Decrypt"]
            Resource = [var.kms_key_arn]
          }
        ] : []
      )
    )
  })
}

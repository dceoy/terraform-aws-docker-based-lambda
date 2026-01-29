resource "aws_lambda_function" "function" {
  # checkov:skip=CKV_AWS_173: env var encryption is optional per deployment
  # checkov:skip=CKV_AWS_272: code signing is managed outside this module
  function_name                  = local.lambda_function_name
  description                    = local.lambda_function_name
  role                           = aws_iam_role.function.arn
  package_type                   = "Image"
  image_uri                      = local.lambda_image_uri
  architectures                  = var.lambda_architectures
  memory_size                    = var.lambda_memory_size
  timeout                        = var.lambda_timeout
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  publish                        = true
  logging_config {
    log_group             = aws_cloudwatch_log_group.function.name
    log_format            = var.lambda_logging_config_log_format
    application_log_level = var.lambda_logging_config_log_format == "Text" ? null : var.lambda_logging_config_application_log_level
    system_log_level      = var.lambda_logging_config_log_format == "Text" ? null : var.lambda_logging_config_system_log_level
  }
  tracing_config {
    mode = var.lambda_tracing_config_mode
  }
  dynamic "ephemeral_storage" {
    for_each = var.lambda_ephemeral_storage_size != null ? [true] : []
    content {
      size = var.lambda_ephemeral_storage_size
    }
  }
  dynamic "image_config" {
    for_each = length(var.lambda_image_config_entry_point) > 0 || length(var.lambda_image_config_command) > 0 || var.lambda_image_config_working_directory != null ? [true] : []
    content {
      entry_point       = var.lambda_image_config_entry_point
      command           = var.lambda_image_config_command
      working_directory = var.lambda_image_config_working_directory
    }
  }
  dynamic "environment" {
    for_each = length(keys(var.lambda_environment_variables)) > 0 ? [true] : []
    content {
      variables = var.lambda_environment_variables
    }
  }
  dynamic "vpc_config" {
    for_each = length(var.lambda_vpc_config_subnet_ids) > 0 && length(var.lambda_vpc_config_security_group_ids) > 0 ? [true] : []
    content {
      subnet_ids                  = var.lambda_vpc_config_subnet_ids
      security_group_ids          = var.lambda_vpc_config_security_group_ids
      ipv6_allowed_for_dual_stack = var.lambda_vpc_config_ipv6_allowed_for_dual_stack
    }
  }
  dynamic "dead_letter_config" {
    for_each = var.lambda_dead_letter_sqs_queue_arn != null ? [true] : []
    content {
      target_arn = var.lambda_dead_letter_sqs_queue_arn
    }
  }
  tags = {
    Name       = local.lambda_function_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

# trivy:ignore:avd-aws-0017
resource "aws_cloudwatch_log_group" "function" {
  # checkov:skip=CKV_AWS_338: retention is configured via variable per environment
  name              = "/${var.system_name}/${var.env_type}/lambda/${local.lambda_function_name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/lambda/${local.lambda_function_name}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_lambda_alias" "function" {
  name             = local.lambda_alias_name
  description      = "Alias for the latest version of ${aws_lambda_function.function.function_name}"
  function_name    = aws_lambda_function.function.function_name
  function_version = aws_lambda_function.function.version
}

resource "aws_lambda_provisioned_concurrency_config" "function" {
  count                             = var.lambda_provisioned_concurrent_executions > -1 ? 1 : 0
  function_name                     = aws_lambda_function.function.function_name
  qualifier                         = aws_lambda_alias.function.name
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions
  skip_destroy                      = false
}

resource "aws_lambda_function_event_invoke_config" "function" {
  count                        = var.lambda_on_success_sqs_queue_arn != null || var.lambda_on_failure_sqs_queue_arn != null ? 1 : 0
  function_name                = aws_lambda_function.function.function_name
  maximum_event_age_in_seconds = var.lambda_maximum_event_age_in_seconds
  maximum_retry_attempts       = var.lambda_maximum_retry_attempts
  qualifier                    = aws_lambda_function.function.version
  destination_config {
    dynamic "on_success" {
      for_each = var.lambda_on_success_sqs_queue_arn != null ? [true] : []
      content {
        destination = var.lambda_on_success_sqs_queue_arn
      }
    }
    dynamic "on_failure" {
      for_each = var.lambda_on_failure_sqs_queue_arn != null ? [true] : []
      content {
        destination = var.lambda_on_failure_sqs_queue_arn
      }
    }
  }
}

resource "aws_iam_role" "function" {
  name                  = "${var.system_name}-${var.env_type}-lambda-execution-iam-role"
  description           = "Lambda execution IAM role"
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
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-lambda-execution-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "function" {
  role_name = aws_iam_role.function.name
  policy_arns = compact([
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    var.s3_iam_policy_arn
  ])
}

resource "aws_iam_role_policy" "function" {
  name = "${var.system_name}-${var.env_type}-lambda-execution-logs-iam-policy"
  role = aws_iam_role.function.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid      = "AllowDescribeLogGroups"
          Effect   = "Allow"
          Action   = ["logs:DescribeLogGroups"]
          Resource = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:*"]
        },
        {
          Sid    = "AllowLogStreamAccess"
          Effect = "Allow"
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ]
          Resource = ["${aws_cloudwatch_log_group.function.arn}:*"]
        }
      ],
      (
        var.lambda_dead_letter_sqs_queue_arn != null || var.lambda_on_success_sqs_queue_arn != null || var.lambda_on_failure_sqs_queue_arn != null ? [
          {
            Sid    = "AllowSQSSendMessage"
            Effect = "Allow"
            Action = ["sqs:SendMessage"]
            Resource = compact([
              var.lambda_dead_letter_sqs_queue_arn,
              var.lambda_on_success_sqs_queue_arn,
              var.lambda_on_failure_sqs_queue_arn
            ])
          }
        ] : []
      ),
      (
        var.kms_key_arn != null ? [
          {
            Sid      = "AllowKMSAccess"
            Effect   = "Allow"
            Action   = ["kms:GenerateDataKey"]
            Resource = [var.kms_key_arn]
          }
        ] : []
      )
    )
  })
}

resource "aws_iam_role" "client" {
  count                 = var.create_lambda_client_iam_role ? 1 : 0
  name                  = "${var.system_name}-${var.env_type}-lambda-client-iam-role"
  description           = "Lambda client IAM role"
  force_detach_policies = true
  path                  = "/"
  max_session_duration  = var.lambda_client_iam_role_max_session_duration
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRootAccountToAssumeRole"
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
      }
    ]
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-lambda-client-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "client" {
  count       = length(aws_iam_role.client) > 0 ? 1 : 0
  role_name   = aws_iam_role.client[count.index].name
  policy_arns = var.lambda_client_iam_role_managed_policy_arns
}

resource "aws_iam_role_policy" "client" {
  count = length(aws_iam_role.client) > 0 ? 1 : 0
  name  = "${var.system_name}-${var.env_type}-lambda-client-iam-policy"
  role  = aws_iam_role.client[count.index].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "AllowLambdaInvokeFunction"
          Effect = "Allow"
          Action = [
            "lambda:Get*",
            "lambda:List*",
            "lambda:InvokeFunction"
          ]
          Resource = ["arn:aws:lambda:${local.region}:${local.account_id}:function:*"]
          Condition = {
            StringEquals = {
              "aws:ResourceTag/SystemName" = var.system_name
              "aws:ResourceTag/EnvType"    = var.env_type
            }
          }
        },
        {
          Sid    = "AllowCloudWatchLogsReadOnlyAccess"
          Effect = "Allow"
          Action = [
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:GetLogEvents",
            "logs:FilterLogEvents",
            "logs:StartQuery",
            "logs:StopQuery",
            "logs:DescribeQueries",
            "logs:GetLogGroupFields",
            "logs:GetLogRecord",
            "logs:GetQueryResults"
          ]
          Resource = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:*"]
          Condition = {
            StringEquals = {
              "aws:ResourceTag/SystemName" = var.system_name
              "aws:ResourceTag/EnvType"    = var.env_type
            }
          }
        },
      ],
      (
        var.lambda_dead_letter_sqs_queue_arn != null || var.lambda_on_success_sqs_queue_arn != null || var.lambda_on_failure_sqs_queue_arn != null ? [
          {
            Sid    = "AllowSQSReadOnlyAccess"
            Effect = "Allow"
            Action = [
              "sqs:GetQueueAttributes",
              "sqs:GetQueueUrl",
              "sqs:ListDeadLetterSourceQueues",
              "sqs:ListQueues",
              "sqs:ListMessageMoveTasks",
              "sqs:ListQueueTags"
            ]
            Resource = ["arn:aws:sqs:${local.region}:${local.account_id}:*"]
          }
        ] : []
      ),
      (
        var.lambda_dead_letter_sqs_queue_arn != null || var.lambda_on_success_sqs_queue_arn != null || var.lambda_on_failure_sqs_queue_arn != null ? [
          {
            Sid    = "AllowSQSReadWriteAccess"
            Effect = "Allow"
            Action = [
              "sqs:ReceiveMessage",
              "sqs:DeleteMessage"
            ]
            Resource = ["arn:aws:sqs:${local.region}:${local.account_id}:*"]
            Condition = {
              StringEquals = {
                "aws:ResourceTag/SystemName" = var.system_name
                "aws:ResourceTag/EnvType"    = var.env_type
              }
            }
          }
        ] : []
      ),
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

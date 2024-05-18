resource "aws_lambda_function" "function" {
  function_name                  = local.lambda_function_name
  description                    = local.lambda_function_name
  role                           = aws_iam_role.function.arn
  package_type                   = "Image"
  image_uri                      = local.lambda_image_uri
  architectures                  = var.lambda_architecture != null ? [var.lambda_architecture] : null
  memory_size                    = var.lambda_memory_size
  timeout                        = var.lambda_timeout
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
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
    for_each = var.lambda_ephemeral_storage_size == null ? [] : [true]
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
    for_each = length(keys(var.lambda_environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.lambda_environment_variables
    }
  }
  tags = {
    Name    = local.lambda_function_name
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_cloudwatch_log_group" "function" {
  name              = "/${var.system_name}/${var.env_type}/lambda/${local.lambda_function_name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/lambda/${local.lambda_function_name}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_lambda_provisioned_concurrency_config" "function" {
  count                             = var.lambda_provisioned_concurrent_executions > -1 ? 1 : 0
  function_name                     = aws_lambda_function.function.function_name
  qualifier                         = aws_lambda_function.function.version
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions
}

resource "aws_iam_role" "function" {
  name        = "${var.system_name}-${var.env_type}-lambda-execution-iam-role"
  path        = "/"
  description = "Lambda execution IAM role"
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
  managed_policy_arns = compact([
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    aws_iam_policy.logs.arn,
    var.s3_iam_policy_arn
  ])
  tags = {
    Name    = "${var.system_name}-${var.env_type}-lambda-execution-role"
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_iam_policy" "logs" {
  name        = "${var.system_name}-${var.env_type}-cloudwatch-logs-policy"
  description = "CloudWatch logs policy"
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowKMSDecrypt"
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = [var.kms_key_arn]
      },
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
    ]
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-cloudwatch-logs-policy"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

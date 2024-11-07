resource "aws_kinesis_firehose_delivery_stream" "logs" {
  for_each    = local.source_cloudwatch_logs_log_group_names
  name        = "${var.system_name}-${var.env_type}-${each.key}-s3-firehose-stream"
  destination = "extended_s3"
  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose[0].arn
    bucket_arn          = "arn:aws:s3:::${var.destination_s3_bucket_id}"
    prefix              = "logs/${trim(each.value, "/")}/!{timestamp:yyyy/MM/dd/HH}/output/"
    error_output_prefix = "logs/${trim(each.value, "/")}/!{timestamp:yyyy/MM/dd/HH}/error/"
    buffer_size         = var.firehose_extended_s3_configuration_buffer_size
    buffer_interval     = var.firehose_extended_s3_configuration_buffer_interval
    compression_format  = var.firehose_extended_s3_configuration_compression_format
    custom_time_zone    = var.firehose_extended_s3_configuration_custom_time_zone
    kms_key_arn         = var.destination_s3_kms_key_arn
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose[0].name
      log_stream_name = aws_cloudwatch_log_stream.firehose[each.key].name
    }
  }
  tags = {
    Name    = "${var.system_name}-${var.env_type}-${each.key}-s3-firehose-stream"
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_iam_role" "firehose" {
  count                 = length(local.source_cloudwatch_logs_log_group_names) > 0 ? 1 : 0
  name                  = "${var.system_name}-${var.env_type}-s3-firehose-stream-iam-role"
  description           = "Data Firehose IAM role for S3"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFirehoseServiceToAssumeRole"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name    = "${var.system_name}-${var.env_type}-s3-firehose-stream-iam-role"
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_iam_role_policy" "firehose" {
  count = length(local.source_cloudwatch_logs_log_group_names) > 0 ? 1 : 0
  name  = "${var.system_name}-${var.env_type}-s3-firehose-stream-iam-role-policy"
  role  = aws_iam_role.firehose[0].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "AllowS3Access"
          Effect = "Allow"
          Action = [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
          ]
          Resource = [
            "arn:aws:s3:::${var.destination_s3_bucket_id}",
            "arn:aws:s3:::${var.destination_s3_bucket_id}/*"
          ]
        },
        {
          Sid      = "AllowKMSGenerateDataKey"
          Effect   = "Allow"
          Action   = ["kms:GenerateDataKey"]
          Resource = [var.destination_s3_kms_key_arn]
        },
        {
          Sid      = "AllowLogsPutLogEvents"
          Effect   = "Allow"
          Action   = ["logs:PutLogEvents"]
          Resource = ["${aws_cloudwatch_log_group.firehose[0].arn}:*"]
        }
      ],
      (
        var.kms_key_arn != null || var.destination_s3_kms_key_arn != null ? [
          {
            Sid    = "AllowKMSGenerateDataKey"
            Effect = "Allow"
            Action = ["kms:GenerateDataKey"]
            Resource = compact([
              var.kms_key_arn,
              var.destination_s3_kms_key_arn
            ])
          }
        ] : []
      )
    )
  })
}

# trivy:ignore:avd-aws-0017
resource "aws_cloudwatch_log_group" "firehose" {
  count             = length(local.source_cloudwatch_logs_log_group_names) > 0 ? 1 : 0
  name              = "/${var.system_name}/${var.env_type}/firehose"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/firehose"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_cloudwatch_log_stream" "firehose" {
  for_each       = local.source_cloudwatch_logs_log_group_names
  name           = each.key
  log_group_name = aws_cloudwatch_log_group.firehose[0].name
}

resource "aws_cloudwatch_log_subscription_filter" "logs" {
  for_each        = aws_kinesis_firehose_delivery_stream.logs
  name            = "${var.system_name}-${var.env_type}-${each.key}-log-subscription-filter"
  log_group_name  = local.source_cloudwatch_logs_log_group_names[each.key]
  filter_pattern  = ""
  distribution    = "ByLogStream"
  role_arn        = aws_iam_role.logs[0].arn
  destination_arn = each.value.arn
}

resource "aws_iam_role" "logs" {
  count                 = length(local.source_cloudwatch_logs_log_group_names) > 0 ? 1 : 0
  name                  = "${var.system_name}-${var.env_type}-cloudwatch-log-subscription-filter-iam-role"
  description           = "CloudWatch Log subscription filter IAM role"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLogsServiceToAssumeRole"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "logs.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name    = "${var.system_name}-${var.env_type}-cloudwatch-log-subscription-filter-iam-role"
    System  = var.system_name
    EnvType = var.env_type
  }
}

resource "aws_iam_role_policy" "logs" {
  count = length(local.source_cloudwatch_logs_log_group_names) > 0 ? 1 : 0
  name  = "${var.system_name}-${var.env_type}-cloudwatch-log-subscription-filter-iam-role-policy"
  role  = aws_iam_role.logs[0].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid      = "AllowFirehosePutRecord"
          Effect   = "Allow"
          Action   = ["firehose:PutRecord"]
          Resource = values(aws_kinesis_firehose_delivery_stream.logs)[*].arn
        }
      ],
      length(var.source_cloudwatch_logs_kms_key_arns) > 0 ? [
        {
          Sid      = "AllowKMSDecrypt"
          Effect   = "Allow"
          Action   = ["kms:Decrypt"]
          Resource = values(var.source_cloudwatch_logs_kms_key_arns)
        }
      ] : []
    )
  })
}

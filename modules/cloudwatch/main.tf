resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/${var.system_name}/${var.env_type}/lambda"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/lambda"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_policy" "logs" {
  name = "${var.system_name}-${var.env_type}-cloudwatch-logs-policy"
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
        Resource = ["${aws_cloudwatch_log_group.lambda.arn}:*"]
      }
    ]
  })
  path = "/"
  tags = {
    Name       = "${var.system_name}-${var.env_type}-cloudwatch-logs-policy"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

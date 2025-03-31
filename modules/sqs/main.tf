resource "aws_sqs_queue" "sqs_dead_letter" {
  count                             = var.create_sqs_queues ? 1 : 0
  name                              = "${var.system_name}-${var.env_type}-sqs-dead-letter-sqs-queue"
  visibility_timeout_seconds        = var.sqs_visibility_timeout_seconds
  message_retention_seconds         = var.sqs_message_retention_seconds
  max_message_size                  = var.sqs_max_message_size
  delay_seconds                     = var.sqs_delay_seconds
  receive_wait_time_seconds         = var.sqs_receive_wait_time_seconds
  fifo_queue                        = var.sqs_fifo_queue
  content_based_deduplication       = var.sqs_fifo_queue ? var.sqs_content_based_deduplication : null
  deduplication_scope               = var.sqs_fifo_queue ? var.sqs_deduplication_scope : null
  fifo_throughput_limit             = var.sqs_fifo_queue ? var.sqs_fifo_throughput_limit : null
  sqs_managed_sse_enabled           = var.kms_key_arn == null ? true : null
  kms_master_key_id                 = var.kms_key_arn
  kms_data_key_reuse_period_seconds = var.kms_key_arn != null ? var.sqs_kms_data_key_reuse_period_seconds : null
  tags = {
    Name       = "${var.system_name}-${var.env_type}-sqs-dead-letter-sqs-queue"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_sqs_queue" "lambda_dead_letter" {
  count                      = var.create_sqs_queues ? 1 : 0
  name                       = "${var.system_name}-${var.env_type}-lambda-dead-letter-sqs-queue"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_dead_letter[0].arn
    maxReceiveCount     = var.sqs_redrive_policy_max_receive_count
  })
  fifo_queue                        = var.sqs_fifo_queue
  content_based_deduplication       = var.sqs_fifo_queue ? var.sqs_content_based_deduplication : null
  deduplication_scope               = var.sqs_fifo_queue ? var.sqs_deduplication_scope : null
  fifo_throughput_limit             = var.sqs_fifo_queue ? var.sqs_fifo_throughput_limit : null
  sqs_managed_sse_enabled           = var.kms_key_arn == null ? true : null
  kms_master_key_id                 = var.kms_key_arn
  kms_data_key_reuse_period_seconds = var.kms_key_arn != null ? var.sqs_kms_data_key_reuse_period_seconds : null
  tags = {
    Name       = "${var.system_name}-${var.env_type}-lambda-dead-letter-sqs-queue"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_sqs_queue" "lambda_on_success" {
  count                      = var.create_sqs_queues ? 1 : 0
  name                       = "${var.system_name}-${var.env_type}-lambda-on-success-sqs-queue"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_dead_letter[0].arn
    maxReceiveCount     = var.sqs_redrive_policy_max_receive_count
  })
  fifo_queue                        = var.sqs_fifo_queue
  content_based_deduplication       = var.sqs_fifo_queue ? var.sqs_content_based_deduplication : null
  deduplication_scope               = var.sqs_fifo_queue ? var.sqs_deduplication_scope : null
  fifo_throughput_limit             = var.sqs_fifo_queue ? var.sqs_fifo_throughput_limit : null
  sqs_managed_sse_enabled           = var.kms_key_arn == null ? true : null
  kms_master_key_id                 = var.kms_key_arn
  kms_data_key_reuse_period_seconds = var.kms_key_arn != null ? var.sqs_kms_data_key_reuse_period_seconds : null
  tags = {
    Name       = "${var.system_name}-${var.env_type}-lambda-on-success-sqs-queue"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_sqs_queue" "lambda_on_failure" {
  count                      = var.create_sqs_queues ? 1 : 0
  name                       = "${var.system_name}-${var.env_type}-lambda-on-failure-sqs-queue"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_dead_letter[0].arn
    maxReceiveCount     = var.sqs_redrive_policy_max_receive_count
  })
  fifo_queue                        = var.sqs_fifo_queue
  content_based_deduplication       = var.sqs_fifo_queue ? var.sqs_content_based_deduplication : null
  deduplication_scope               = var.sqs_fifo_queue ? var.sqs_deduplication_scope : null
  fifo_throughput_limit             = var.sqs_fifo_queue ? var.sqs_fifo_throughput_limit : null
  sqs_managed_sse_enabled           = var.kms_key_arn == null ? true : null
  kms_master_key_id                 = var.kms_key_arn
  kms_data_key_reuse_period_seconds = var.kms_key_arn != null ? var.sqs_kms_data_key_reuse_period_seconds : null
  tags = {
    Name       = "${var.system_name}-${var.env_type}-lambda-on-failure-sqs-queue"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

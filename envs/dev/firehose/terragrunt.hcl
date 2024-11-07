include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    awslogs_s3_bucket_id = "my-logs-bucket"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "lambda" {
  config_path = "../lambda"
  mock_outputs = {
    lambda_cloudwatch_logs_log_group_name = "/aws/lambda/my-lambda"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  kms_key_arn = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  source_cloudwatch_logs_log_group_names = {
    my-lambda = "/aws/lambda/my-lambda"
  }
  source_cloudwatch_logs_kms_key_arns = {
    my-lambda = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  }
  destination_s3_bucket_id   = dependency.s3.outputs.awslogs_s3_bucket_id
  destination_s3_kms_key_arn = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
}

terraform {
  source = "${get_repo_root()}/modules/firehose"
}

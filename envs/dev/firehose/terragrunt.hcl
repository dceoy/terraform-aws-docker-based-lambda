include "root" {
  path   = find_in_parent_folders("root.hcl")
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
    lambda_function_arn                   = "arn:aws:lambda:us-east-1:123456789012:function:my-lambda"
    lambda_cloudwatch_logs_log_group_name = "/aws/lambda/my-lambda"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  kms_key_arn = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  source_cloudwatch_logs_log_group_names = {
    "${include.root.inputs.lambda_function_name}" = dependency.lambda.outputs.lambda_cloudwatch_logs_log_group_name
  }
  source_cloudwatch_logs_kms_key_arns = {
    "${include.root.inputs.lambda_function_name}" = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  }
  destination_s3_bucket_id   = dependency.s3.outputs.awslogs_s3_bucket_id
  destination_s3_kms_key_arn = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
}

terraform {
  source = "${get_repo_root()}/modules/firehose"
}

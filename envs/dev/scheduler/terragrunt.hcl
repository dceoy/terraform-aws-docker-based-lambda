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

dependency "sqs" {
  config_path = "../sqs"
  mock_outputs = {
    scheduler_dead_letter_sqs_queue_arn = "arn:aws:sqs:us-east-1:123456789012:scheduler-dead-letter-queue"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "lambda" {
  config_path = "../lambda"
  mock_outputs = {
    lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:my-function"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  lambda_function_arn                 = dependency.lambda.outputs.lambda_function_arn
  kms_key_arn                         = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  scheduler_dead_letter_sqs_queue_arn = dependency.sqs.outputs.scheduler_dead_letter_sqs_queue_arn
}

terraform {
  source = "${get_repo_root()}/modules/scheduler"
}

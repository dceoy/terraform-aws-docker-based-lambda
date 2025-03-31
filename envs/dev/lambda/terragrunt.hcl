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
    s3_iam_policy_arn = "arn:aws:iam::123456789012:policy/s3-iam-policy"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "docker" {
  config_path = "../docker"
  mock_outputs = {
    docker_registry_primary_image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-function:latest"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "sqs" {
  config_path = "../sqs"
  mock_outputs = {
    lambda_dead_letter_sqs_queue_arn = "arn:aws:sqs:us-east-1:123456789012:lambda-dead-letter"
    lambda_on_success_sqs_queue_arn  = "arn:aws:sqs:us-east-1:123456789012:lambda-on-success"
    lambda_on_failure_sqs_queue_arn  = "arn:aws:sqs:us-east-1:123456789012:lambda-on-failure"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  lambda_image_uri                           = dependency.docker.outputs.docker_registry_primary_image_uri
  kms_key_arn                                = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  s3_iam_policy_arn                          = dependency.s3.outputs.s3_iam_policy_arn
  lambda_client_iam_role_managed_policy_arns = dependency.s3.outputs.s3_iam_policy_arn != null ? [dependency.s3.outputs.s3_iam_policy_arn] : []
  lambda_dead_letter_sqs_queue_arn           = dependency.sqs.outputs.lambda_dead_letter_sqs_queue_arn
  lambda_on_success_queue_arn                = dependency.sqs.outputs.lambda_on_success_sqs_queue_arn
  lambda_on_failure_queue_arn                = dependency.sqs.outputs.lambda_on_failure_sqs_queue_arn
}

terraform {
  source = "${get_repo_root()}/modules/lambda"
}

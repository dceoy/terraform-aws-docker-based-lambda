include "root" {
  path = find_in_parent_folders()
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

inputs = {
  lambda_image_uri  = dependency.docker.outputs.docker_registry_primary_image_uri
  kms_key_arn       = dependency.kms.outputs.kms_key_arn
  s3_iam_policy_arn = dependency.s3.outputs.s3_iam_policy_arn
}

terraform {
  source = "${get_repo_root()}/modules/lambda"
}

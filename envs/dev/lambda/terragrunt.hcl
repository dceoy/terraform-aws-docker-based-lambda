include "root" {
  path = find_in_parent_folders()
}

dependency "ecr" {
  config_path = "../ecr"
  mock_outputs = {
    ecr_repository_id = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-function"
  }
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    s3_iam_policy_arn = "arn:aws:iam::123456789012:policy/s3-iam-policy"
  }
}

inputs = {
  ecr_repository_url = dependency.ecr.outputs.ecr_repository_url
  kms_key_arn        = dependency.kms.outputs.kms_key_arn
  s3_iam_policy_arn  = dependency.s3.outputs.s3_iam_policy_arn
}

terraform {
  source = "${get_path_to_repo_root()}/modules/lambda"
}

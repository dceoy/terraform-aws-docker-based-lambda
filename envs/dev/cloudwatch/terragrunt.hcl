include "root" {
  path = find_in_parent_folders()
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

inputs = {
  kms_key_arn = dependency.kms.outputs.kms_key_arn
}

terraform {
  source = "${get_path_to_repo_root()}/modules/cloudwatch"
}

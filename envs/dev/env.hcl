locals {
  terraform_s3_bucket                       = "tfstate-us-east-1-${get_aws_account_id()}"
  terraform_dynamodb_table                  = "tfstate-lock"
  region                                    = "us-east-1"
  system_name                               = "dbl"
  env_type                                  = "dev"
  ecr_repository_name                       = "lambda-hello-world"
  ecr_image_tag_mutability                  = "MUTABLE"
  ecr_force_delete                          = true
  ecr_lifecycle_policy_image_count          = 1
  s3_expiration_days                        = null
  s3_force_destroy                          = true
  s3_noncurrent_version_expiration_days     = 7
  s3_abort_incomplete_multipart_upload_days = 7
  enable_s3_server_access_logging           = true
}

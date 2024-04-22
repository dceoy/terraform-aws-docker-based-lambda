locals {
  account_id               = get_aws_account_id()
  region                   = "us-east-1"
  terraform_s3_bucket      = "tfstate-${local.region}-${local.account_id}"
  terraform_dynamodb_table = "tfstate-lock"
  system_name              = "dbl"
  env_type                 = "dev"
}

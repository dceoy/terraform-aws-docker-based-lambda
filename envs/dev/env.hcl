locals {
  terraform_s3_bucket      = "tfstate-us-east-1-${get_aws_account_id()}"
  terraform_dynamodb_table = "tfstate-lock"
  region                   = "us-east-1"
  system_name              = "dbl"
  env_type                 = "dev"
  ecr_repository_name      = "lambda-hello-world"
  ecr_image_tag_mutability = "MUTABLE"
  ecr_force_delete         = true
}

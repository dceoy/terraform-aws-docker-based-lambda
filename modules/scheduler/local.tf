data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id           = data.aws_caller_identity.current.account_id
  region               = data.aws_region.current.name
  lambda_function_name = split(":", var.lambda_function_arn)[6]
}

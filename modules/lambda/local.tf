data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id           = data.aws_caller_identity.current.account_id
  region               = data.aws_region.current.name
  lambda_function_name = var.lambda_function_name != null ? var.lambda_function_name : "${var.system_name}-${var.env_type}-lambda-function"
  lambda_image_uri     = var.lambda_image_uri != null ? var.lambda_image_uri : "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${local.lambda_function_name}:latest"
}

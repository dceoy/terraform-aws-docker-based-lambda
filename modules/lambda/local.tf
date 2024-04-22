data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id       = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.name
  lambda_image_uri = var.lambda_image_uri != null ? var.lambda_image_uri : "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.lambda_function_name}:latest"
}

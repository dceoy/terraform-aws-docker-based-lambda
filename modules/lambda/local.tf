data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  ecr_repository_url = var.ecr_repository_url != null ? var.ecr_repository_url : "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.lambda_function_name}"
}

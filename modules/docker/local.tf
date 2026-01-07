data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id                   = data.aws_caller_identity.current.account_id
  region                       = data.aws_region.current.id
  docker_image_repository      = var.ecr_repository_url != null ? var.ecr_repository_url : "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.system_name}-${var.env_type}-lambda-function"
  docker_image_primary_name    = "${local.docker_image_repository}:${var.docker_image_primary_tag}"
  docker_image_secondary_names = [for t in var.ecr_image_secondary_tags : (strcontains(t, ":") ? t : "${local.docker_image_repository}:${t}")]
}

data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  host = var.docker_host
  registry_auth {
    address  = split("/", local.docker_image_repository)[0]
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

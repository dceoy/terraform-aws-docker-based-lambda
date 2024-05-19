data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  trigger_files_sha1 = sha1(join(",", [for f in setunion([for p in var.docker_image_build_trigger_file_patterns : fileset(var.docker_image_build_context, p)]...) : "${f}:${filesha1("${var.docker_image_build_context}/${f}")}"]))
  docker_image_name  = var.ecr_repository_url != null ? var.ecr_repository_url : "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.system_name}-${var.env_type}-lambda-function"
}

data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  registry_auth {
    address  = split("/", local.docker_image_name)[0]
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

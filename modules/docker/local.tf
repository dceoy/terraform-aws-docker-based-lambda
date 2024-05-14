data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  ecr_address       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
  docker_image_name = var.docker_image_name != null ? var.docker_image_name : "${var.system_name}-${var.env_type}-lambda-function"
}

data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

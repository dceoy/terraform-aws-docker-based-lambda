locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  extra_arguments "parallelism" {
    commands = get_terraform_commands_that_need_parallelism()
    arguments = [
      "-parallelism=4"
    ]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = local.env_vars.locals.terraform_s3_bucket
    key            = "${basename(get_repo_root())}/${local.env_vars.locals.system_name}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.env_vars.locals.region
    encrypt        = true
    dynamodb_table = local.env_vars.locals.terraform_dynamodb_table
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.env_vars.locals.region}"
  default_tags {
    tags = {
      SystemName = "${local.env_vars.locals.system_name}"
      EnvType    = "${local.env_vars.locals.env_type}"
    }
  }
}
EOF
}

catalog {
  urls = [
    "${get_path_to_repo_root()}/modules/ecr"
  ]
}

inputs = {
  system_name              = local.env_vars.locals.system_name
  env_type                 = local.env_vars.locals.env_type
  ecr_repository_name      = local.env_vars.locals.ecr_repository_name
  ecr_image_tag_mutability = local.env_vars.locals.ecr_image_tag_mutability
  ecr_force_delete         = local.env_vars.locals.ecr_force_delete
}

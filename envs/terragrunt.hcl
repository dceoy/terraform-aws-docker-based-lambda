locals {
  image_name          = "lambda-hello-world"
  lambda_architecture = "arm64"
  docker_image_build_platforms = {
    "x86_64" = "linux/amd64"
    "arm64"  = "linux/arm64"
  }
  repo_root   = get_repo_root()
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  ecr_address = "${local.env_vars.locals.account_id}.dkr.ecr.${local.env_vars.locals.region}.amazonaws.com"
}

terraform {
  extra_arguments "parallelism" {
    commands = get_terraform_commands_that_need_parallelism()
    arguments = [
      "-parallelism=2"
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
    key            = "${basename(local.repo_root)}/${local.env_vars.locals.system_name}/${path_relative_to_include()}/terraform.tfstate"
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
    "github.com/dceoy/terraform-aws-vpc-for-slc",
    "${local.repo_root}/modules/kms",
    "${local.repo_root}/modules/ecr",
    "${local.repo_root}/modules/docker",
    "${local.repo_root}/modules/lambda"
  ]
}

inputs = {
  system_name                                           = local.env_vars.locals.system_name
  env_type                                              = local.env_vars.locals.env_type
  create_kms_key                                        = true
  kms_key_deletion_window_in_days                       = 30
  kms_key_rotation_period_in_days                       = 365
  ecr_repository_name                                   = local.image_name
  ecr_image_secondary_tags                              = compact(split(",", get_env("DOCKER_METADATA_OUTPUT_TAGS", "latest")))
  ecr_image_tag_mutability                              = "MUTABLE"
  ecr_force_delete                                      = true
  ecr_lifecycle_policy_semver_image_count               = 9999
  ecr_lifecycle_policy_any_image_count                  = 10
  ecr_lifecycle_policy_untagged_image_days              = 7
  create_io_s3_bucket                                   = true
  create_awslogs_s3_bucket                              = true
  create_s3logs_s3_bucket                               = true
  s3_force_destroy                                      = true
  s3_noncurrent_version_expiration_days                 = 7
  s3_abort_incomplete_multipart_upload_days             = 7
  s3_expired_object_delete_marker                       = true
  enable_s3_server_access_logging                       = true
  docker_image_force_remove                             = true
  docker_image_build                                    = local.env_vars.locals.docker_image_build
  docker_image_build_context                            = "${local.repo_root}/app"
  docker_image_build_dockerfile                         = "Dockerfile"
  docker_image_build_build_args                         = {}
  docker_image_build_platform                           = local.docker_image_build_platforms[local.lambda_architecture]
  docker_image_build_target                             = "app"
  docker_image_primary_tag                              = get_env("DOCKER_PRIMARY_TAG", format("sha-%s", run_cmd("--terragrunt-quiet", "git", "rev-parse", "--short", "HEAD")))
  docker_host                                           = get_env("DOCKER_HOST", "unix:///var/run/docker.sock")
  cloudwatch_logs_retention_in_days                     = 30
  iam_role_force_detach_policies                        = true
  create_lambda_client_iam_role                         = true
  lambda_client_iam_role_max_session_duration           = 3600
  enable_asynchronous_invocations                       = true
  lambda_function_name                                  = local.image_name
  lambda_architectures                                  = [local.lambda_architecture]
  lambda_memory_size                                    = 128
  lambda_timeout                                        = 3
  lambda_reserved_concurrent_executions                 = -1
  lambda_logging_config_log_format                      = "JSON"
  lambda_logging_config_application_log_level           = "INFO"
  lambda_logging_config_shadow_log_level                = "INFO"
  lambda_ephemeral_storage_size                         = 512
  lambda_tracing_config_mode                            = "Active"
  lambda_provisioned_concurrent_executions              = -1
  lambda_maximum_event_age_in_seconds                   = 21600
  lambda_maximum_retry_attempts                         = 0
  sqs_visibility_timeout_seconds                        = 60
  sqs_message_retention_seconds                         = 345600
  sqs_max_message_size                                  = 262144
  sqs_delay_seconds                                     = 0
  sqs_receive_wait_time_seconds                         = 20
  sqs_redrive_policy_max_receive_count                  = 1000
  sqs_kms_data_key_reuse_period_seconds                 = 300
  firehose_extended_s3_configuration_buffering_size     = 5
  firehose_extended_s3_configuration_buffering_interval = 300
  firehose_extended_s3_configuration_compression_format = "GZIP"
  firehose_extended_s3_configuration_custom_time_zone   = "UTC"
  # lambda_image_config_entry_point             = []
  # lambda_image_config_command                 = []
  # lambda_image_config_working_directory       = null
  # lambda_environment_variables                = {}
}

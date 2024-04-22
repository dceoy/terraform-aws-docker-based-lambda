include "root" {
  path = find_in_parent_folders()
}

dependency "ecr" {
  config_path = "../ecr"
  mock_outputs = {
    ecr_repository_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-function"
  }
}

inputs = {
  docker_image_name = dependency.ecr.outputs.ecr_repository_url
}

terraform {
  source = "${get_repo_root()}/modules/docker"
}

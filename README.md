terraform-aws-docker-based-lambda
=================================

Terraform modules of AWS Lambda with Docker image

[![CI](https://github.com/dceoy/terraform-aws-docker-based-lambda/actions/workflows/ci.yml/badge.svg)](https://github.com/dceoy/terraform-aws-docker-based-lambda/actions/workflows/ci.yml)

Installation
------------

1.  Check out the repository.

    ```sh
    $ git clone https://github.com/dceoy/terraform-aws-docker-based-lambda.git
    $ cd terraform-aws-docker-based-lambda
    ````

2.  Install [AWS CLI](https://aws.amazon.com/cli/) and set `~/.aws/config` and `~/.aws/credentials`.

3.  Install [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/).

4.  Build the Docker image.

    ```sh
    $ ./docker_buildx_bake.sh
    ```

5.  Initialize Terraform working directories.

    ```sh
    $ terragrunt run-all init --working-dir='envs/dev/' -upgrade -reconfigure
    ```

6.  Generates a speculative execution plan. (Optional)

    ```sh
    $ terragrunt run-all plan --working-dir='envs/dev/'
    ```

7.  Creates or updates infrastructure.

    ```sh
    $ terragrunt run-all apply --working-dir='envs/dev/' --non-interactive
    ```

Usage
-----

```sh
$ aws lambda invoke --function-name lambda-hello-world /dev/stdout
```

Cleanup
-------

```sh
$ terragrunt run-all destroy --working-dir='envs/dev/' --non-interactive
```

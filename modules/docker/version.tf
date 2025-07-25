terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6.0"
    }
  }
}

terraform {
  #required_providers{
  #    docker = {
  #        source  = "kreuzwerker/docker"
  #    }
  #    aws = {
  #        source = "hashicorp/aws"
  #        version = "~> 3.27"
  #    }
  #}
  #required_version = ">= 0.13"

  backend "s3" {
    profile = "lab1"
    region  = "us-east-1"
    key     = "terraform.tfstate"
    bucket  = "firstbucket1122334"

  }
}
terraform {
  backend "s3" {
    bucket         = "weather-forecast-tf-state"
    key            = "statefiles/eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "weather-forecast-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "weather-forecast-tf-state"
    key    = "statefiles/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_ecr_repository" "weather_app" {
  name                 = var.cluster_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    weather_nodes = {
      desired_size   = var.desired_capacity
      min_size       = var.min_size
      max_size       = var.max_size
      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"
    }
  }
}

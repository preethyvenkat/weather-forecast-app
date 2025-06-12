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

# Remote state to fetch VPC outputs
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "weather-forecast-tf-state"
    key            = "statefiles/vpc/terraform.tfstate"
    region         = "us-east-1"
  }
}

# ECR repository (optional, used by CI/CD to push images)
resource "aws_ecr_repository" "weather_app" {
  name                 = var.cluster_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# EKS Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.33"

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  enable_irsa     = true
  manage_aws_auth = true

  eks_managed_node_groups = {
    weather_nodes = {
      desired_size   = var.desired_capacity
      min_size       = var.min_size
      max_size       = var.max_size
      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"
    }
  }

  # Grant EC2 GitHub runner access to cluster
  map_roles = [
    {
      rolearn  = "arn:aws:iam::141409473062:role/GitHubActionsRunnerRole"
      username = "github-runner"
      groups   = ["system:masters"]
    }
  ]
}

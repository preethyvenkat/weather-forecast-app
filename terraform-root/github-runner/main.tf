terraform {
  backend "s3" {
    bucket         = "weather-forecast-tf-state"
    key            = "statefiles/github-runner/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "weather-forecast-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# Import shared VPC outputs
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "weather-forecast-tf-state"
    key    = "statefiles/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# Security Group allowing SSH and HTTPS
resource "aws_security_group" "github_runner_sg" {
  name        = "github-runner-sg"
  description = "Allow SSH and HTTPS"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For SSH (you can restrict to your IP)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For GitHub HTTPS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "github_runner" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(data.terraform_remote_state.vpc.outputs.public_subnets, 0)
  vpc_security_group_ids      = [aws_security_group.github_runner_sg.id]
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name

  iam_instance_profile = aws_iam_instance_profile.runner_profile.name

  tags = {
    Name = "GitHub Runner"
  }

  user_data = file("setup-runner.sh")  # Bootstrap script to install Docker, GitHub runner, etc.
}

# IAM Role for GitHub Runner
resource "aws_iam_role" "runner_role" {
  name = "GitHubActionsRunnerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "runner_attach" {
  role       = aws_iam_role.runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # Least privilege recommended in real setups
}

resource "aws_iam_instance_profile" "runner_profile" {
  name = "GitHubRunnerProfile"
  role = aws_iam_role.runner_role.name
}

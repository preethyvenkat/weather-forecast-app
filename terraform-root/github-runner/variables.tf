variable "region" {
  default = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID for EC2 runner"
  default     = "ami-0fc5d935ebf8bc3bc" # Replace with latest Ubuntu ARM64 or x86_64 AMI
}

variable "instance_type" {
  default = "t3.medium"
}

variable "ssh_key_name" {
  description = "Your AWS EC2 key pair name"
}

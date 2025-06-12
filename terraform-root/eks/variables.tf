variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "weather-app"
}

variable "node_instance_type" {
  default     = "t3.medium"
  description = "Node group EC2 instance type"
}

variable "desired_capacity" {
  default     = 2
}

variable "min_size" {
  default     = 1
}

variable "max_size" {
  default     = 3
}

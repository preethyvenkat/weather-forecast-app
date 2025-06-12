variable "vpc_name" {
  description = "Name of the VPC"
  default     = "weather-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "project" {
  description = "Project tag for all resources"
  default     = "weather-forecast"
}

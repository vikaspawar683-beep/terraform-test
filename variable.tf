variable "aws_region" {
  default = "ap-south-1"
}

variable "vpc_id" {
  description = "Your VPC ID"
}

variable "subnet_ids" {
  type = list(string)
  description = "Public subnet IDs for ALB"
}

variable "ami_id" {
  default = "ami-0f5ee92e2d63afc18" # Amazon Linux (update if needed)
}

variable "instance_type" {
  default = "t2.micro"
}


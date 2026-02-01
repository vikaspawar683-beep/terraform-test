variable "aws_region" {
  default = "ap-south-1"
}

variable "vpc_id" {
  description = "vpc-08ea4136d31e1607d"
}

variable "subnet_ids" {
  type = list(string)
  description = "Public subnet IDs for ALB"
}

variable "ami_id" {
  default = "ami-019715e0d74f695be" # Amazon Linux (update if needed)
}

variable "instance_type" {
  default = "t3.micro"
}


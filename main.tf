provider "aws"{
    region = "us-east-1"
}

module "ec2_instance" {
    source = "C:/terraform/modules/ec2"
    ami = var.ami
    instance_type = var.instance_type
    name = var.name
    environment = var.environment
}

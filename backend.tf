terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-12345"
    key            = "alb-project/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

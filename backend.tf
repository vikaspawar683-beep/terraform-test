terraform {
  backend "s3" {
    bucket         = "s3-bucket-beckend"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    #dynamodb_table = "terraform-lock-table"
  }
}

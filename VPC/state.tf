terraform {
  backend "s3" {
    bucket = "backend-terraform-task"
    key    = "ap-south-1/VPC/terraform.tfstate"
    region = "ap-south-1"
    profile = "default"
  }
}

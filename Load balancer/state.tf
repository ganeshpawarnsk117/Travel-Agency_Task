terraform {
  backend "s3" {
    bucket  = "backend-terraform-task"
    key     = "ap-south-1/load_balancer/terraform.tfstate"
    region  = "ap-south-1"
    profile = "default"
  }
}

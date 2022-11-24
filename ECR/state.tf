terraform {
  backend "s3" {
    bucket  = "backend-terraform-task"
    key     = "ap-south-1/ecr_repo/terraform.tfstate"
    region  = "ap-south-1"
    profile = "default" 
   }
}

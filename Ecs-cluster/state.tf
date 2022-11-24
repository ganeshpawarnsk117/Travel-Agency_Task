terraform {
  backend "s3" {
    bucket  = "backend-terraform-task"
    key     = "ap-south-1/ecs_cluster/terraform.tfstate"
    region  = "ap-south-1"
    profile = "default" 
   }
}

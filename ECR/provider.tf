provider "aws" {
  profile = "default"
  default_tags {
    tags = {
      Environment = var.environment
      Project_Name        = "travel-Agency"
    }
  }
}

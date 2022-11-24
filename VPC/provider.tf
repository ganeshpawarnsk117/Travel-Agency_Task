provider "aws" {
  
    profile = "default"
    default_tags {
    tags = {
      Environment = var.environment
      Name        = "Travel-Agency"
    }
  }
}
  

/*provider "aws" {
  profile = "default"
  alias = "default"
}*/

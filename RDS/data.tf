data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "net" {
  filter {
    name   = "tag:Name"
    values = ["demo_VPC"]
  }
}

data "aws_subnet" "net_public" {
  vpc_id = data.aws_vpc.net.id

  filter {
    name   = "tag:Name"
    values = ["demo-PublicSubnet-1"]
  }
}

data "aws_subnet" "net_public1" {
  vpc_id = data.aws_vpc.net.id

  filter {
    name   = "tag:Name"
    values = ["demo-PublicSubnet-0"]
  }
}

/*data "aws_subnet" "net_public_az2" {
  vpc_id = data.aws_vpc.net.id

  filter {
    name   = "tag:Name"
    values = ["prod-PublicSubnet-2"]
  }
}*/

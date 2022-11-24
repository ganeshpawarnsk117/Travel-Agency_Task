/*provider "aws" {
  region  = var.aws_region
  #profile = "default"
}*/
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr-block
  tags = {
    "Name" = "${var.env}_VPC"
  }
}

# Create var.priv-count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = var.priv-count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = {
    "Name" = "${var.env}-PrivateSubnet-${count.index}"
  }
}
# Create var.priv-count private subnets, each in a different AZ for database
resource "aws_subnet" "private_db" {
  count             = var.db_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, var.priv-count + var.pub-count +count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = {
    "Name" = "${var.env}-Database-Subnet-${count.index}"
  }
}
# Create var.pub-count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = var.pub-count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.priv-count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    "Name" = "${var.env}-PublicSubnet-${count.index}"
  }
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.env}-gateway"
  }
}

#Create Nat Gateway
resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "${var.env}-EIP"
  }
}

resource "aws_nat_gateway" "Nat-GW" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.env}-NatGW"
  }
  depends_on = [aws_eip.eip]
}


# Route the public subnet traffic through the IGW
resource "aws_route_table" "public" {
  count  = var.pub-count
  vpc_id = aws_vpc.main.id
  #route_table_id         = aws_vpc.main.main_route_table_id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    "Name" = "${var.env}-RoutePublic-${count.index}"
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "public" {
  count          = var.pub-count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}


# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = var.priv-count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat-GW.id
  }

  tags = {
    "Name" = "${var.env}-RoutePrivate-${count.index}"
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.priv-count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}


resource "aws_route_table" "private_db" {
  count  = var.db_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat-GW.id
  }

  tags = {
    "Name" = "${var.env}-RouteDBPrivate-${count.index}"
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private_db" {
  count          = var.priv-count
  subnet_id      = element(aws_subnet.private_db.*.id, count.index)
  route_table_id = element(aws_route_table.private_db.*.id, count.index)
}


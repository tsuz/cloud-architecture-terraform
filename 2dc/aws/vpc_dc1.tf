
resource "aws_vpc" "dc1" {
  provider             = aws.dc1
  cidr_block           = var.dc1_vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-dc1-vpc"
  }
}

resource "aws_internet_gateway" "dc1" {
  provider = aws.dc1
  vpc_id   = aws_vpc.dc1.id
  tags = {
    Name = "internet_gateway"
  }
}

# Create Public Subnet 1
# terraform aws create subnet
resource "aws_subnet" "dc1-public" {
  provider                = aws.dc1
  for_each                = var.dc1_zones.public_subnets
  vpc_id                  = aws_vpc.dc1.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-${each.value.name}"
  }
}

# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "dc1" {
  provider = aws.dc1
  for_each = var.dc1_zones.public_subnets
  vpc_id   = aws_vpc.dc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dc1.id
  }
  tags = {
    Name = "${var.name}-${each.value.name}"
  }
}

# Associate Public Subnet 1 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet-route-table-association" {
  provider       = aws.dc1
  for_each       = var.dc1_zones.public_subnets
  subnet_id      = aws_subnet.dc1-public[each.key].id
  route_table_id = aws_route_table.dc1[each.key].id
}
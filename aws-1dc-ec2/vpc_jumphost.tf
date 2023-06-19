
resource "aws_vpc" "jumphost" {
  cidr_block = var.jumphost_vpc_cidr_block

  provider             = aws.dc1
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-jumphost-vpc"
  }
}

# Create public jumphost subnet
resource "aws_subnet" "jumphost-public" {
  provider                = aws.dc1
  vpc_id                  = aws_vpc.jumphost.id
  cidr_block              = var.jumphost_vpc_cidr_block
  availability_zone       = var.jumphost_az
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-jumphost-subnet-${var.jumphost_az}"
  }
}

# Create Route Table and Add private Route
# terraform aws create route table
resource "aws_route_table" "jumphost" {
  provider = aws.dc1
  vpc_id   = aws_vpc.jumphost.id

  tags = {
    Name = "${var.name}-jumphost-route-table"
  }
}


# Internet gateway required for SSH connection to jumphost
resource "aws_internet_gateway" "jumphost" {
  vpc_id = aws_vpc.jumphost.id

  tags = {
    Name = "${var.name}-jumphost-ig"
  }
}

resource "aws_route" "jumphost_ssh" {
  route_table_id         = aws_route_table.jumphost.id
  gateway_id             = aws_internet_gateway.jumphost.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "jumphost_to_ec2" {
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.ec2.id
  route_table_id            = aws_route_table.jumphost.id
  destination_cidr_block    = var.ec2_vpc_cidr_block
}

# Associate private Subnet 1 to "private Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "jumphost-route-table-association" {
  provider       = aws.dc1
  subnet_id      = aws_subnet.jumphost-public.id
  route_table_id = aws_route_table.jumphost.id
}
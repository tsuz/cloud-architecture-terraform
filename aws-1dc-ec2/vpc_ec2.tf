
resource "aws_vpc" "ec2" {
  cidr_block = var.ec2_vpc_cidr_block

  provider             = aws.dc1
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-ec2-vpc"
  }
}

# Create Private Subnet
resource "aws_subnet" "ec2-private" {
  provider          = aws.dc1
  for_each          = var.dc1_zones.private_subnets
  vpc_id            = aws_vpc.ec2.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.name}-${each.value.name}"
  }
}

# Create Route Table and Add private Route
# terraform aws create route table
resource "aws_route_table" "ec2" {
  provider = aws.dc1
  for_each = var.dc1_zones.private_subnets
  vpc_id   = aws_vpc.ec2.id

  route {
    cidr_block = var.jumphost_vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.jumphost.id
  }

  tags = {
    Name = "${var.name}-aws-route-table-${each.value.name}"
  }
}

# Associate private Subnet 1 to "private Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "dc1-route-table-association" {
  provider       = aws.dc1
  for_each       = var.dc1_zones.private_subnets
  subnet_id      = aws_subnet.ec2-private[each.key].id
  route_table_id = aws_route_table.ec2[each.key].id
}
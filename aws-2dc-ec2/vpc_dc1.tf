
resource "aws_vpc" "dc1" {
  cidr_block = var.dc1_vpc_cidr_block

  provider             = aws.dc1
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-dc1-vpc"
  }
}

# Create Private Subnet
resource "aws_subnet" "dc1-private" {
  provider          = aws.dc1
  for_each          = var.dc1_zones.private_subnets
  vpc_id            = aws_vpc.dc1.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.name}-${each.value.name}"
  }
}


resource "aws_vpc" "dc3" {
  cidr_block = var.dc3_vpc_cidr_block

  provider             = aws.dc3
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-dc3-vpc"
  }
}

# Create Private Subnet
resource "aws_subnet" "dc3-private" {
  provider          = aws.dc3
  for_each          = var.dc3_zones.private_subnets
  vpc_id            = aws_vpc.dc3.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.name}-${each.value.name}"
  }
}

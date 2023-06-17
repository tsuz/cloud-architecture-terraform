
resource "aws_vpc" "dc2" {
  cidr_block = var.dc2_vpc_cidr_block

  provider             = aws.dc2
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-dc2-vpc"
  }
}

# Create Private Subnet
resource "aws_subnet" "dc2-private" {
  provider          = aws.dc2
  for_each          = var.dc2_zones.private_subnets
  vpc_id            = aws_vpc.dc2.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.name}-${each.value.name}"
  }
}

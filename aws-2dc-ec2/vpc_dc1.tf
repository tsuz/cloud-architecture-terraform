
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


# Allow indirect outbound internet access for private subnets
resource "aws_internet_gateway" "igw_dc1" {
  vpc_id = aws_vpc.dc1.id

  tags = {
    Name = "${var.name}-dc1-igw"
  }
}

# Create Public Subnet required for an access to public internet
resource "aws_subnet" "dc1-public" {
  provider                = aws.dc1
  for_each                = var.dc1_zones.public_subnets
  vpc_id                  = aws_vpc.dc1.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-${each.value.name}"
  }
}

resource "aws_eip" "dc1-eip" {
  provider = aws.dc1
  vpc      = true
  for_each = var.dc1_zones.public_subnets

  tags = {
    Name = "${var.name}-eip-${each.value.name}"
  }
}

# Connect NAT to elastic IP for public access
resource "aws_nat_gateway" "dc1-nat" {
  for_each      = var.dc1_zones.public_subnets
  allocation_id = aws_eip.dc1-eip[each.key].id
  subnet_id     = aws_subnet.dc1-public[each.key].id

  tags = {
    Name = "${var.name}-nat-${each.value.name}"
  }

  depends_on = [aws_internet_gateway.igw_dc1]
}

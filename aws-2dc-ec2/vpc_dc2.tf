
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



# Allow indirect outbound internet access for private subnets
resource "aws_internet_gateway" "igw_dc2" {
  provider = aws.dc2
  vpc_id   = aws_vpc.dc2.id

  tags = {
    Name = "${var.name}-dc2-igw"
  }
}

# Create Public Subnet required for an access to public internet
resource "aws_subnet" "dc2-public" {
  provider                = aws.dc2
  for_each                = var.dc2_zones.public_subnets
  vpc_id                  = aws_vpc.dc2.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-${each.value.name}"
  }
}

resource "aws_eip" "dc2-eip" {
  provider = aws.dc2
  vpc      = true
  for_each = var.dc2_zones.public_subnets

  tags = {
    Name = "${var.name}-eip-${each.value.name}"
  }
}

# Connect NAT to elastic IP for public access
resource "aws_nat_gateway" "dc2-nat" {
  provider      = aws.dc2
  for_each      = var.dc2_zones.public_subnets
  allocation_id = aws_eip.dc2-eip[each.key].id
  subnet_id     = aws_subnet.dc2-public[each.key].id

  tags = {
    Name = "${var.name}-nat-${each.value.name}"
  }

  depends_on = [aws_internet_gateway.igw_dc2]
}

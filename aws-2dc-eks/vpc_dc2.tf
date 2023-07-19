
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
    Name                                        = "${var.name}-${each.value.name}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.name}-dc2-eks" = "owned"
  }
}

# Create Public Subnet to enable pulling ECR images by Fargate
resource "aws_subnet" "dc2-public" {
  provider                = aws.dc2
  for_each                = var.dc2_zones.public_subnets
  vpc_id                  = aws_vpc.dc2.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.name}-${each.value.name}-public"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.name}-dc2-eks" = "owned"
  }
}

# Allow indirect outbound internet access for private subnets
resource "aws_internet_gateway" "dc2-igw" {
  provider = aws.dc2
  vpc_id   = aws_vpc.dc2.id

  tags = {
    Name = "${var.name}-dc2-igw"
  }
}

resource "aws_eip" "dc2-eip" {
  provider = aws.dc2
  vpc      = true
  for_each = var.dc2_zones.public_subnets

  tags = {
    Name = "${var.name}-dc2-eip-${each.value.name}"
  }
}

# Allow outbound internet to pull ECR images
resource "aws_nat_gateway" "dc2-nat" {
  provider      = aws.dc2
  for_each      = var.dc2_zones.public_subnets
  allocation_id = aws_eip.dc2-eip[each.key].id
  subnet_id     = aws_subnet.dc2-public[each.key].id

  tags = {
    Name = "${var.name}-dc2-nat-${each.value.name}"
  }

  depends_on = [aws_internet_gateway.dc2-igw]
}

# Create Route Table and Add private Route
# terraform aws create route table
resource "aws_route_table" "dc2-private" {
  provider = aws.dc2
  for_each = var.dc2_zones.private_subnets
  vpc_id   = aws_vpc.dc2.id

  route {
    cidr_block                = var.dc1_vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    # Use replace to chnage "private-1a" to "public-1a"
    nat_gateway_id = aws_nat_gateway.dc2-nat[replace(each.key, "private", "public")].id
  }

  tags = {
    Name = "${var.name}-${each.value.name}"
  }
}

# Associate private Subnet 1 to "private Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "dc2-private-route-table-association" {
  provider       = aws.dc2
  for_each       = var.dc2_zones.private_subnets
  subnet_id      = aws_subnet.dc2-private[each.key].id
  route_table_id = aws_route_table.dc2-private[each.key].id
}

resource "aws_route_table" "dc2-public" {
  provider = aws.dc2
  for_each = var.dc2_zones.public_subnets
  vpc_id   = aws_vpc.dc2.id

  route {
    cidr_block                = var.dc1_vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dc2-igw.id
  }

  tags = {
    Name = "${var.name}-${each.value.name}"
  }
}

# Associate public Subnet 1 to "public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "dc2-public-route-table-association" {
  provider       = aws.dc2
  for_each       = var.dc2_zones.public_subnets
  subnet_id      = aws_subnet.dc2-public[each.key].id
  route_table_id = aws_route_table.dc2-public[each.key].id
}
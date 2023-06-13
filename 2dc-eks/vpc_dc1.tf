
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
    Name                                        = "${var.name}-${each.value.name}-private"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.name}-dc1-eks" = "owned"
  }
}

# Create Public Subnet to enable pulling ECR images by Fargate
resource "aws_subnet" "dc1-public" {
  provider                = aws.dc1
  for_each                = var.dc1_zones.public_subnets
  vpc_id                  = aws_vpc.dc1.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.name}-${each.value.name}-public"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.name}-dc1-eks" = "owned"
  }
}
# Allow indirect outbound internet access for private subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dc1.id

  tags = {
    Name = "${var.name}-dc1-igw"
  }
}

resource "aws_eip" "dc1-eip" {
  vpc      = true
  for_each = var.dc1_zones.public_subnets

  tags = {
    Name = "${var.name}-dc1-eip-${each.value.name}"
  }
}

# Allow outbound internet to pull ECR images
resource "aws_nat_gateway" "dc1-nat" {
  for_each      = var.dc1_zones.public_subnets
  allocation_id = aws_eip.dc1-eip[each.key].id
  subnet_id     = aws_subnet.dc1-public[each.key].id

  tags = {
    Name = "${var.name}-dc1-nat-${each.value.name}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Create Route Table and Add private Route
# terraform aws create route table
resource "aws_route_table" "dc1-private" {
  provider = aws.dc1
  for_each = var.dc1_zones.private_subnets
  vpc_id   = aws_vpc.dc1.id

  route {
    cidr_block                = var.dc2_vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    # Use replace to chnage "private-1a" to "public-1a"
    nat_gateway_id = aws_nat_gateway.dc1-nat[replace(each.key, "private", "public")].id
  }

  tags = {
    Name = "${var.name}-${each.value.name}"
  }
}

# Associate private Subnet 1 to "private Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "dc1-private-route-table-association" {
  provider       = aws.dc1
  for_each       = var.dc1_zones.private_subnets
  subnet_id      = aws_subnet.dc1-private[each.key].id
  route_table_id = aws_route_table.dc1-private[each.key].id
}

resource "aws_route_table" "dc1-public" {
  provider = aws.dc1
  for_each = var.dc1_zones.public_subnets
  vpc_id   = aws_vpc.dc1.id

  route {
    cidr_block                = var.dc2_vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name}-${each.value.name}"
  }
}

# Associate public Subnet 1 to "public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "dc1-public-route-table-association" {
  provider       = aws.dc1
  for_each       = var.dc1_zones.public_subnets
  subnet_id      = aws_subnet.dc1-public[each.key].id
  route_table_id = aws_route_table.dc1-public[each.key].id
}


# DC2 to Jumphost connection
resource "aws_route" "dc2_to_jumphost" {
  provider                  = aws.dc2
  for_each                  = aws_route_table.dc2-private
  vpc_peering_connection_id = aws_vpc_peering_connection.jumphost_dc2.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.jumphost_vpc_cidr_block
}

# AWS Route from DC2 to DC1
resource "aws_route" "dc2_to_dc1_private" {
  provider                  = aws.dc2
  for_each                  = aws_route_table.dc2-private
  vpc_peering_connection_id = aws_vpc_peering_connection.dc1_dc2.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.dc1_vpc_cidr_block
}


# Create Route Table for private subnets
resource "aws_route_table" "dc2-private" {
  provider = aws.dc2
  for_each = var.dc2_zones.private_subnets
  vpc_id   = aws_vpc.dc2.id

  tags = {
    Name = "${var.name}-aws-route-table-${each.value.name}"
  }
}

# # Associate private Subnet 1 to "private Route Table"
resource "aws_route_table_association" "dc2-route-table-association" {
  provider       = aws.dc2
  for_each       = var.dc2_zones.private_subnets
  subnet_id      = aws_subnet.dc2-private[each.key].id
  route_table_id = aws_route_table.dc2-private[each.key].id
}


# Create Route Table for public subnets
resource "aws_route_table" "dc2-public" {
  provider = aws.dc2
  for_each = var.dc2_zones.public_subnets
  vpc_id   = aws_vpc.dc2.id

  tags = {
    Name = "${var.name}-aws-route-table-${each.value.name}"
  }
}


# AWS Route from DC2 to DC1
resource "aws_route" "dc2_to_public" {
  provider               = aws.dc2
  for_each               = aws_route_table.dc2-public
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_dc2.id
}


# Associate public Subnet to "public Route Table"
resource "aws_route_table_association" "dc2-public-route-table-association" {
  provider       = aws.dc2
  for_each       = var.dc2_zones.public_subnets
  subnet_id      = aws_subnet.dc2-public[each.key].id
  route_table_id = aws_route_table.dc2-public[each.key].id
}

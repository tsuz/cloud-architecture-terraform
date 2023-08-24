

# DC1 to Jumphost connection
resource "aws_route" "dc1_to_jumphost_private" {
  provider                  = aws.dc1
  for_each                  = aws_route_table.dc1-private
  vpc_peering_connection_id = aws_vpc_peering_connection.jumphost_dc1.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.jumphost_vpc_cidr_block
}

# AWS Route from DC1 to DC2
resource "aws_route" "dc1_to_dc2" {
  provider                  = aws.dc1
  for_each                  = aws_route_table.dc1-private
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.dc2_accept_dc1.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.dc2_vpc_cidr_block
}

# AWS Route from private subnet to public subnet
resource "aws_route" "dc1_private_to_public" {
  provider               = aws.dc1
  for_each               = aws_route_table.dc1-private
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = each.value.id
  # replace "private-1a" to "public-1a"
  nat_gateway_id = aws_nat_gateway.dc1-nat[replace(each.key, "private", "public")].id
}

# Create Route Table for private subnets
resource "aws_route_table" "dc1-private" {
  provider = aws.dc1
  for_each = var.dc1_zones.private_subnets
  vpc_id   = aws_vpc.dc1.id

  tags = {
    Name = "${var.name}-aws-route-table-${each.value.name}"
  }
}

# # Associate private Subnet 1 to "private Route Table"
resource "aws_route_table_association" "dc1-route-table-association" {
  provider       = aws.dc1
  for_each       = var.dc1_zones.private_subnets
  subnet_id      = aws_subnet.dc1-private[each.key].id
  route_table_id = aws_route_table.dc1-private[each.key].id
}


# Create Route Table for public subnets
resource "aws_route_table" "dc1-public" {
  provider = aws.dc1
  for_each = var.dc1_zones.public_subnets
  vpc_id   = aws_vpc.dc1.id

  tags = {
    Name = "${var.name}-aws-route-table-${each.value.name}"
  }
}

# AWS Route from DC1 to jumphost
resource "aws_route" "dc1_to_igw" {
  provider               = aws.dc1
  for_each               = aws_route_table.dc1-public
  gateway_id             = aws_internet_gateway.igw_dc1.id
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
}


# Associate public Subnet to "public Route Table"
resource "aws_route_table_association" "dc1-public-route-table-association" {
  provider       = aws.dc1
  for_each       = var.dc1_zones.public_subnets
  subnet_id      = aws_subnet.dc1-public[each.key].id
  route_table_id = aws_route_table.dc1-public[each.key].id
}

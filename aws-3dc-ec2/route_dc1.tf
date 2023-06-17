
# Route table of DC1
resource "aws_route_table" "dc1" {
  provider = aws.dc1
  for_each = var.dc1_zones.private_subnets
  vpc_id   = aws_vpc.dc1.id

  tags = {
    Name = "${var.name}-dc1-${each.value.name}"
  }
}

# Associate subnet to the route table
resource "aws_route_table_association" "dc1" {
  provider       = aws.dc1
  for_each       = var.dc1_zones.private_subnets
  subnet_id      = aws_subnet.dc1-private[each.key].id
  route_table_id = aws_route_table.dc1[each.key].id
}


# DC1 to Jumphost connection
resource "aws_route" "dc1_to_jumphost" {
  provider                  = aws.dc1
  for_each                  = aws_route_table.dc1
  vpc_peering_connection_id = aws_vpc_peering_connection.jumphost.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.jumphost_vpc_cidr_block
}

# AWS Route from DC1 to DC2
resource "aws_route" "dc1_to_dc2" {
  provider                  = aws.dc1
  for_each                  = aws_route_table.dc1
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.dc2_accept_dc1.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.dc2_vpc_cidr_block
}

# AWS Route from DC1 to DC3
resource "aws_route" "dc1_to_dc3" {
  provider                  = aws.dc1
  for_each                  = aws_route_table.dc1
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.dc3_accept_dc1.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.dc3_vpc_cidr_block
}


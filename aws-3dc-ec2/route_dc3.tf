
# Create Route Table of dc3
resource "aws_route_table" "dc3" {
  provider = aws.dc3
  for_each = var.dc3_zones.private_subnets
  vpc_id   = aws_vpc.dc3.id

  tags = {
    Name = "${var.name}-dc3-${each.value.name}"
  }
}

# Create Route Table association of dc3
resource "aws_route_table_association" "dc3" {
  provider       = aws.dc3
  for_each       = var.dc3_zones.private_subnets
  subnet_id      = aws_subnet.dc3-private[each.key].id
  route_table_id = aws_route_table.dc3[each.key].id
}


# dc3 to Jumphost connection
resource "aws_route" "dc3_to_jumphost" {
  provider                  = aws.dc3
  for_each                  = aws_route_table.dc3
  vpc_peering_connection_id = aws_vpc_peering_connection.jumphost_dc3.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.jumphost_vpc_cidr_block
}

# AWS Route from dc3 to DC1
resource "aws_route" "dc3_to_dc1" {
  provider                  = aws.dc3
  for_each                  = aws_route_table.dc3
  vpc_peering_connection_id = aws_vpc_peering_connection.dc1_dc3.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.dc1_vpc_cidr_block
}

# AWS Route from dc3 to DC2
resource "aws_route" "dc3_to_dc2" {
  provider                  = aws.dc3
  for_each                  = aws_route_table.dc3
  vpc_peering_connection_id = aws_vpc_peering_connection.dc2_dc3.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.dc2_vpc_cidr_block
}


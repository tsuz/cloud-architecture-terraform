
# Create Route Table of DC2
resource "aws_route_table" "dc2" {
  provider = aws.dc2
  for_each = var.dc2_zones.private_subnets
  vpc_id   = aws_vpc.dc2.id

  tags = {
    Name = "${var.name}-dc2-${each.value.name}"
  }
}

# Create Route Table association of DC2
resource "aws_route_table_association" "dc2" {
  provider       = aws.dc2
  for_each       = var.dc2_zones.private_subnets
  subnet_id      = aws_subnet.dc2-private[each.key].id
  route_table_id = aws_route_table.dc2[each.key].id
}


# DC2 to Jumphost connection
resource "aws_route" "dc2_to_jumphost" {
  provider                  = aws.dc2
  for_each                  = aws_route_table.dc2
  vpc_peering_connection_id = aws_vpc_peering_connection.jumphost_dc2.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.jumphost_vpc_cidr_block
}

# AWS Route from DC2 to DC1
resource "aws_route" "dc2_to_dc1" {
  provider                  = aws.dc2
  for_each                  = aws_route_table.dc2
  vpc_peering_connection_id = aws_vpc_peering_connection.dc1_dc2.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.dc1_vpc_cidr_block
}

# AWS Route from DC2 to DC3
resource "aws_route" "dc2_to_dc3" {
  provider                  = aws.dc2
  for_each                  = aws_route_table.dc2
  vpc_peering_connection_id = aws_vpc_peering_connection.dc2_dc3.id
  route_table_id            = each.value.id
  destination_cidr_block    = var.dc3_vpc_cidr_block
}



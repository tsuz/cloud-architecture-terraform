
# Create Route Table and Add private Route
# terraform aws create route table
resource "aws_route_table" "jumphost" {
  provider = aws.dc1
  vpc_id   = aws_vpc.jumphost.id

  tags = {
    Name = "${var.name}-jumphost-route-table"
  }
}

# Route between local computer -> Jumphost
# Creates a route for external SSH access
resource "aws_route" "jumphost" {
  route_table_id         = aws_route_table.jumphost.id
  gateway_id             = aws_internet_gateway.jumphost.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "jumphost_to_dc1" {
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.dc1_accept_jumphost.id
  route_table_id            = aws_route_table.jumphost.id
  destination_cidr_block    = var.dc1_vpc_cidr_block
}

resource "aws_route" "jumphost_to_dc2" {
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.dc2_accept_jumphost.id
  route_table_id            = aws_route_table.jumphost.id
  destination_cidr_block    = var.dc2_vpc_cidr_block
}

# Associate private Subnet 1 to "private Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "jumphost-route-table-association" {
  provider       = aws.dc1
  subnet_id      = aws_subnet.jumphost-public.id
  route_table_id = aws_route_table.jumphost.id
}
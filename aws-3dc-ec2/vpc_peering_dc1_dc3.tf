
data "aws_caller_identity" "dc3" {
  provider = aws.dc3
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "dc1_dc3" {
  provider      = aws.dc1
  vpc_id        = aws_vpc.dc1.id
  peer_vpc_id   = aws_vpc.dc3.id
  peer_region   = var.dc3_region
  peer_owner_id = data.aws_caller_identity.dc3.account_id
  auto_accept   = false

  tags = {
    Side = "${var.name}-vpc-dc1-to-dc3"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "dc3_accept_dc1" {
  provider                  = aws.dc3
  vpc_peering_connection_id = aws_vpc_peering_connection.dc1_dc3.id
  auto_accept               = true

  tags = {
    Side = "${var.name}-vpc-dc1-to-dc3"
  }
}


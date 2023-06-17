
data "aws_caller_identity" "dc2" {
  provider = aws.dc2
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "dc1_dc2" {
  provider      = aws.dc1
  vpc_id        = aws_vpc.dc1.id
  peer_vpc_id   = aws_vpc.dc2.id
  peer_region   = var.dc2_region
  peer_owner_id = data.aws_caller_identity.dc2.account_id
  auto_accept   = false

  tags = {
    Side = "${var.name}-vpc-dc1-to-dc2"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "dc2_accept_dc1" {
  provider                  = aws.dc2
  vpc_peering_connection_id = aws_vpc_peering_connection.dc1_dc2.id
  auto_accept               = true

  tags = {
    Side = "${var.name}-vpc-dc1-to-dc2"
  }
}


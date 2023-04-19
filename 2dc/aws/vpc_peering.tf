

data "aws_caller_identity" "requester" {
  provider = aws.dc1
}
data "aws_caller_identity" "accepter" {
  provider = aws.dc2
}

resource "aws_vpc_peering_connection" "requester" {
  vpc_id        = aws_vpc.dc1.id
  peer_vpc_id   = aws_vpc.dc2.id
  peer_region   = var.dc2_region
  peer_owner_id = data.aws_caller_identity.accepter.account_id
  auto_accept   = false

  tags = {
    Side = "${var.name}-vpc-requester"
  }
}


# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.dc2
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  auto_accept               = true

  tags = {
    Side = "${var.name}-vpc-acceptor"
  }
}
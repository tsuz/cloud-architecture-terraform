
data "aws_caller_identity" "dc1" {
  provider = aws.dc1
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "jumphost" {
  provider      = aws.dc1
  vpc_id        = aws_vpc.jumphost.id
  peer_vpc_id   = aws_vpc.dc1.id
  peer_region   = var.dc1_region
  peer_owner_id = data.aws_caller_identity.dc1.account_id
  auto_accept   = false

  tags = {
    Side = "${var.name}-vpc-peering-request-jumphost-dc1"
  }

  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}


# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "dc1_accept_jumphost" {
  provider                  = aws.dc1
  vpc_peering_connection_id = aws_vpc_peering_connection.jumphost.id
  auto_accept               = true

  tags = {
    Side = "${var.name}-vpc-peering-accepter-jumphost-dc1"
  }

  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}
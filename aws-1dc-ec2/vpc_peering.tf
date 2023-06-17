

data "aws_caller_identity" "jumphost" {
  provider = aws.dc1
}

data "aws_caller_identity" "ec2" {
  provider = aws.dc1
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "jumphost" {
  vpc_id        = aws_vpc.ec2.id
  peer_vpc_id   = aws_vpc.jumphost.id
  peer_region   = var.dc1_region
  peer_owner_id = data.aws_caller_identity.ec2.account_id
  auto_accept   = false

  tags = {
    Side = "${var.name}-vpc-jumphost"
  }
}


# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "ec2" {
  provider                  = aws.dc1
  vpc_peering_connection_id = aws_vpc_peering_connection.jumphost.id
  auto_accept               = true

  tags = {
    Side = "${var.name}-vpc-ec2"
  }
}

data "aws_ami" "dc2_ubuntu" {
  provider = aws.dc2
  owners   = ["amazon"]

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "dc2_host" {
  for_each      = aws_subnet.dc2-private
  provider      = aws.dc2
  ami           = data.aws_ami.dc2_ubuntu.id
  instance_type = "r5.large"
  key_name      = var.dc2_ssh_keyname
  vpc_security_group_ids = [
    aws_security_group.dc2.id
  ]
  subnet_id = each.value.id

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name}-dc2-${var.dc2_zones.private_subnets[each.key].az}"
  }
}

resource "aws_security_group" "dc2" {
  provider = aws.dc2
  name     = "${var.name}-dc2"
  vpc_id   = aws_vpc.dc2.id

  ingress {
    description = "Port 22 from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.jumphost_vpc_cidr_block]
  }

  ingress {
    description = "All Internal Access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All Egress Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-jumphost-access"
  }
}

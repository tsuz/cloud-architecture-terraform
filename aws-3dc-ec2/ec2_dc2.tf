
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
  instance_type = var.instance_type
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
    description = "Jumphost access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.jumphost_vpc_cidr_block]
  }

  ingress {
    description = "DC1 access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.dc1_vpc_cidr_block]
  }

  egress {
    description = "DC1 access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.dc1_vpc_cidr_block]
  }

  ingress {
    description = "DC3 access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.dc3_vpc_cidr_block]
  }

  egress {
    description = "DC3 access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.dc3_vpc_cidr_block]
  }

  tags = {
    Name = "${var.name}-dc2"
  }
}

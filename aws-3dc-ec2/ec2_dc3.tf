
data "aws_ami" "dc3_ubuntu" {
  provider = aws.dc3
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

resource "aws_instance" "dc3_host" {
  for_each      = aws_subnet.dc3-private
  provider      = aws.dc3
  ami           = data.aws_ami.dc3_ubuntu.id
  instance_type = var.instance_type
  key_name      = var.dc3_ssh_keyname
  vpc_security_group_ids = [
    aws_security_group.dc3.id
  ]
  subnet_id = each.value.id

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name}-dc3-${var.dc3_zones.private_subnets[each.key].az}"
  }
}

resource "aws_security_group" "dc3" {
  provider = aws.dc3
  name     = "${var.name}-dc3"
  vpc_id   = aws_vpc.dc3.id

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
    description = "DC2 access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.dc2_vpc_cidr_block]
  }

  egress {
    description = "DC2 access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.dc2_vpc_cidr_block]
  }

  tags = {
    Name = "${var.name}-dc3"
  }
}

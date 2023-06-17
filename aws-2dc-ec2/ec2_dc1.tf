
data "aws_ami" "dc1_ubuntu" {
  provider = aws.dc1
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

resource "aws_instance" "dc1_host" {
  for_each = aws_subnet.dc1-private

  ami           = data.aws_ami.dc1_ubuntu.id
  instance_type = "r5.large"
  key_name      = var.dc1_ssh_keyname
  provider      = aws.dc1
  subnet_id     = each.value.id

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  vpc_security_group_ids = [
    aws_security_group.dc1.id
  ]

  tags = {
    Name = "${var.name}-dc1-${var.dc1_zones.private_subnets[each.key].az}"
  }
}


resource "aws_security_group" "dc1" {
  provider = aws.dc1
  name     = "${var.name}-dc1"
  vpc_id   = aws_vpc.dc1.id

  ingress {
    description = "Port 22 from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.jumphost_vpc_cidr_block]
  }

  ingress {
    description = "DC2 internal access"
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
    Name = "${var.name}-ssh"
  }
}

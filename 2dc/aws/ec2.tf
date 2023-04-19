
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

resource "aws_instance" "jumphost" {
  associate_public_ip_address = true
  ami                         = data.aws_ami.dc1_ubuntu.id
  instance_type               = "t2.small"
  key_name                    = "ap_northeast_1_taku"
  provider                    = aws.dc1
  vpc_security_group_ids = [
    aws_security_group.ssh_my_ip.id
  ]
  subnet_id = aws_subnet.dc1-public["public-1a"].id

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name       =  "${var.name}-jumphost"
  }
}


resource "aws_instance" "dc1_host" {

  for_each = aws_subnet.dc1-public

  associate_public_ip_address = true
  ami                         = data.aws_ami.dc1_ubuntu.id
  instance_type               = "t3.xlarge"
  key_name                    = var.dc1_ssh_keyname
  provider                    = aws.dc1
  vpc_security_group_ids = [
    aws_security_group.too_open.id
  ]
  subnet_id = each.value.id

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name}-dc1-${var.dc1_zones.public_subnets[each.key].az}"
  }
}

resource "aws_instance" "dc2_host" {
  for_each = aws_subnet.dc2-public

  provider                    = aws.dc2
  associate_public_ip_address = true
  ami                         = data.aws_ami.dc2_ubuntu.id
  instance_type               = "t3.xlarge"
  key_name                    = var.dc2_ssh_keyname
  vpc_security_group_ids = [
    aws_security_group.dc2_too_open.id
  ]
  subnet_id = each.value.id

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name}-dc2-${var.dc2_zones.public_subnets[each.key].az}"
  }
}
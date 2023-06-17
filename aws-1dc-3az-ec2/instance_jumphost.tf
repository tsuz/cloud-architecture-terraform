
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

resource "aws_instance" "jumphost" {
  associate_public_ip_address = true
  ami                         = data.aws_ami.dc1_ubuntu.id
  instance_type               = "t2.small"
  key_name                    = var.dc1_ssh_keyname
  provider                    = aws.dc1
  vpc_security_group_ids = [
    aws_security_group.ssh.id
  ]
  subnet_id = aws_subnet.jumphost-public.id

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name}-jumphost"
  }
}


output "jumphost_public_ip" {
  value = aws_instance.jumphost.public_ip
}
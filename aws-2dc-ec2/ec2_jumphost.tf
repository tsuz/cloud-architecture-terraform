

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


resource "aws_security_group" "ssh" {
  provider    = aws.dc1
  name        = "${var.name}-ssh-security-group"
  description = "Allow only ssh"
  vpc_id      = aws_vpc.jumphost.id

  ingress {
    description      = "Port 22 from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name}-ssh"
  }
}


resource "aws_instance" "dc1_host" {

  for_each = aws_subnet.ec2-private

  associate_public_ip_address = true
  ami                         = data.aws_ami.dc1_ubuntu.id
  instance_type               = "r5.large"
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
    Name = "${var.name}-dc1-${var.dc1_zones.private_subnets[each.key].az}"
  }
}

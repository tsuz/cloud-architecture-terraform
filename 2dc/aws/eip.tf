
resource "aws_eip" "dc1_eip" {
  for_each = aws_instance.dc1_host
  provider = aws.dc1

  instance = each.value.id
  vpc      = true

  tags = {
    Name = "${var.name}-eip-${each.value.id}"
  }
}

resource "aws_eip" "dc2_eip" {
  provider = aws.dc2
  for_each = aws_instance.dc2_host

  instance = each.value.id
  vpc      = true

  tags = {
    Name = "${var.name}-eip-${each.value.id}"
  }
}
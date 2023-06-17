
resource "aws_vpc" "jumphost" {

  provider             = aws.dc1
  cidr_block           = var.jumphost_vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-jumphost-vpc"
  }
}

# Create public jumphost subnet for external SSH access
resource "aws_subnet" "jumphost-public" {
  provider                = aws.dc1
  vpc_id                  = aws_vpc.jumphost.id
  cidr_block              = var.jumphost_vpc_cidr_block
  availability_zone       = var.jumphost_az
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-jumphost-subnet-${var.jumphost_az}"
  }
}

# Internet gateway required for SSH connection to jumphost
resource "aws_internet_gateway" "jumphost" {
  vpc_id = aws_vpc.jumphost.id

  tags = {
    Name = "${var.name}-jumphost-ig"
  }
}

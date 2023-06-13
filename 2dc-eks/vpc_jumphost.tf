
# # resource "aws_vpc" "jumphost" {

# #   provider             = aws.dc1
# #   enable_dns_hostnames = true
# #   enable_dns_support   = true

# #   tags = {
# #     Name = "${var.name}-jumphost-vpc"
# #   }


# # }

# # Create Private Subnet
# resource "aws_subnet" "jumphost-public" {
#   provider                = aws.dc1

#   vpc_id                  = aws_vpc.jumphost.id
#   availability_zone       = var.jumphost_az

#   tags = {
#     Name = "${var.name}-jumphost-subnet"
#   }
# }

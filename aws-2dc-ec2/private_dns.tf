
# Private zone
resource "aws_route53_zone" "private" {
  name = "${var.name}.internal"

  vpc {
    vpc_id     = aws_vpc.jumphost.id
    vpc_region = var.dc1_region
  }

  vpc {
    vpc_id     = aws_vpc.dc1.id
    vpc_region = var.dc1_region
  }

  vpc {
    vpc_id     = aws_vpc.dc2.id
    vpc_region = var.dc2_region
  }
}

resource "aws_route53_record" "dc1" {
  for_each = aws_instance.dc1_host
  zone_id  = aws_route53_zone.private.zone_id
  name     = "${each.key}.dc1.${var.name}.internal"
  type     = "A"
  ttl      = "60"
  records  = [aws_instance.dc1_host[each.key].private_ip]
}

resource "aws_route53_record" "dc2" {
  for_each = aws_instance.dc2_host
  zone_id  = aws_route53_zone.private.zone_id
  name     = "${each.key}.dc2.${var.name}.internal"
  type     = "A"
  ttl      = "60"
  records  = [aws_instance.dc2_host[each.key].private_ip]
}

resource "aws_route53_vpc_association_authorization" "jumphost" {
  provider = aws.dc1
  vpc_id   = aws_vpc.jumphost.id
  zone_id  = aws_route53_zone.private.id
}

# resource "aws_route53_zone_association" "jumphost" {
#   provider = aws.dc1
#   zone_id  = aws_route53_zone.private.zone_id
#   vpc_id   = aws_vpc.jumphost.id
# }

resource "aws_route53_vpc_association_authorization" "dc2" {
  provider = aws.dc2
  vpc_id   = aws_vpc.dc2.id
  zone_id  = aws_route53_zone.private.id
}

# resource "aws_route53_zone_association" "dc2" {
#   provider = aws.dc2
#   zone_id  = aws_route53_zone.private.zone_id
#   vpc_id   = aws_vpc.dc2.id
# }


output "dc1_instance_dns" {
  value = { for k, v in aws_route53_record.dc1 : k => v.fqdn }
}

output "dc2_instance_dns" {
  value = { for k, v in aws_route53_record.dc2 : k => v.fqdn }
}
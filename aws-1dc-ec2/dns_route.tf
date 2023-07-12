
# Private zone
resource "aws_route53_zone" "private" {
  name = "${var.name}.internal"

  vpc {
    vpc_id = aws_vpc.ec2.id
  }
}

resource "aws_route53_record" "ec2" {
  for_each = aws_instance.dc1_host
  zone_id  = aws_route53_zone.private.zone_id
  name     = "${each.key}.${var.name}.internal"
  type     = "A"
  ttl      = "60"
  records  = [aws_instance.dc1_host[each.key].private_ip]
}

resource "aws_route53_vpc_association_authorization" "example" {
  vpc_id  = aws_vpc.jumphost.id
  zone_id = aws_route53_zone.private.id
}

resource "aws_route53_zone_association" "jumphost" {
  zone_id = aws_route53_zone.private.zone_id
  vpc_id  = aws_vpc.jumphost.id
}

output "dc1_instance_dns" {
  value = { for k, v in aws_route53_record.ec2 : k => v.fqdn }
}
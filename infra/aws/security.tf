resource "aws_security_group" "default" {
  name        = "${var.aws_prefix}-sg"
  description = "Default security group allowing egress only"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "all_ingress_from_deployers_ip" {
  for_each = {
    ssh   = 22
    k8s   = 6443
    http  = 80
    https = 443
  }

  type              = "ingress"
  description       = each.key
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["${data.http.deployer_ip.response_body}/32"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "all_https_from_cloudflare" {
  for_each = {
    https = 443
  }

  type              = "ingress"
  description       = "cloudflare-https"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks
  ipv6_cidr_blocks  = data.cloudflare_ip_ranges.cloudflare.ipv6_cidr_blocks
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "self_ingress" {
  type              = "ingress"
  description       = "self ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.default.id
}

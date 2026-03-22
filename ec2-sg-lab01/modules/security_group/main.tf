resource "aws_security_group" "sg" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id
  tags        = var.tags

  /*
  lifecycle {
    prevent_destroy = true
  }
 */

}

// inbound rules

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_ip4" {
  for_each          = var.inbound_rules_ipv4
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.protocol
  to_port           = each.value.to_port
  description       = each.value.description
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_ip6" {
  for_each          = var.inbound_rules_ipv6
  security_group_id = aws_security_group.sg.id
  cidr_ipv6         = each.value.cidr_ipv6
  from_port         = each.value.from_port
  ip_protocol       = each.value.protocol
  to_port           = each.value.to_port
  description       = each.value.description
}

// outbound rules

resource "aws_vpc_security_group_egress_rule" "egress_rule_ip4" {
  for_each          = var.outbound_rules_ipv4
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.protocol
  description       = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "egress_rule_ip6" {
  for_each          = var.outbound_rules_ipv6
  security_group_id = aws_security_group.sg.id
  cidr_ipv6         = each.value.cidr_ipv6
  ip_protocol       = each.value.protocol
  description       = each.value.description
}
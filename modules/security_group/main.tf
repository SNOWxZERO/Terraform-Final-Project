resource "aws_security_group" "SGs" {
  for_each    = var.security_groups
  name        = "${var.name_prefix}-${each.key}-sg"
  description = each.value.description
  vpc_id      = var.vpc_id


  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = length(ingress.value.cidr_blocks) > 0 ? ingress.value.cidr_blocks : null
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = length(egress.value.cidr_blocks) > 0 ? egress.value.cidr_blocks : null
      description = egress.value.description
    }
  }

  tags = { Name = "${var.name_prefix}-${each.key}-sg" }
}
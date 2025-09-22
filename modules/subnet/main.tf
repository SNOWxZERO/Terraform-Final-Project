resource "aws_subnet" "PubOrPrivSubnet" {
  for_each = var.subnets

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip

  tags = {
    Name = "${var.name_prefix}-${each.key}-subnet"
    Type = each.value.map_public_ip ? "Public" : "Private"
  }
}
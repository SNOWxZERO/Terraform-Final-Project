resource "aws_eip" "nat-eip" {
  for_each = {
    for k, v in var.subnets : k => v
    if v.map_public_ip == true  
  }
  
  domain = "vpc"
  tags = { Name = "${var.name_prefix}-nat-eip-${each.key}" }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  for_each = {
    for k, v in var.subnets : k => v
    if v.map_public_ip == true
  }
  
  allocation_id = aws_eip.nat-eip[each.key].id
  subnet_id     = aws_subnet.PubOrPrivSubnet[each.key].id
  tags = { Name = "${var.name_prefix}-nat-gw-${each.key}" }
  depends_on = [aws_eip.nat-eip]
}
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  
  tags = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route_table" "private" {
  for_each = {
    for k, v in var.subnets_config : k => v  # <- CHANGED
    if v.map_public_ip == false
  }
  
  vpc_id = var.vpc_id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.availability_zone == "us-east-1a" ? var.nat_gateway_ids["public1"] : var.nat_gateway_ids["public2"]
  }
  
  tags = { Name = "${var.name_prefix}-private-rt-${each.key}" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = {
    for k, v in var.subnets_config : k => v  
    if v.map_public_ip == true
  }

  subnet_id      = var.subnet_ids[each.key]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = {
    for k, v in var.subnets_config : k => v
    if v.map_public_ip == false
  }

  subnet_id      = var.subnet_ids[each.key]
  route_table_id = aws_route_table.private[each.key].id
}
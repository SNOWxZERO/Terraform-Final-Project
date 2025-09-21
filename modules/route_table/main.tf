resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route_table" "private" {
  for_each = {
    for k, v in var.subnets : k => v
    if v.map_public_ip == false
  }
  
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.availability_zone == "us-east-1a" ? 
                     aws_nat_gateway.nat["public1"].id : 
                     aws_nat_gateway.nat["public2"].id
  }
  
  tags = { Name = "${var.name_prefix}-private-rt-${each.key}" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = {
    for k, v in var.subnets : k => v
    if v.map_public_ip == true
  }
  
  subnet_id      = aws_subnet.PubOrPrivSubnet[each.key].id
  route_table_id = aws_route_table.public.id
}

# Private associations  
resource "aws_route_table_association" "private_assoc" {
  for_each = {
    for k, v in var.subnets : k => v
    if v.map_public_ip == false
  }
  
  subnet_id      = aws_subnet.PubOrPrivSubnet[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
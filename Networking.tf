resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-igw" }
}

resource "aws_subnet" "PubOrPrivSubnet" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip

  tags = {
    Name = "${var.name_prefix}-${each.key}-subnet"
  }
}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id = aws_subnet.PubOrPrivSubnet["public"].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat-eip" {
  tags = { Name = "${var.name_prefix}-nat-eip" }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.PubOrPrivSubnet["public"].id
  tags = { Name = "${var.name_prefix}-nat-gw" }
  depends_on = [aws_eip.nat-eip]
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
    tags = { Name = "${var.name_prefix}-private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id = aws_subnet.PubOrPrivSubnet["private"].id
  route_table_id = aws_route_table.private.id
  depends_on = [aws_nat_gateway.nat]
}

resource "aws_security_group" "SGs" {
  for_each    = var.security_groups
  name        = "${var.name_prefix}-${each.key}-sg"
  description = each.value.description
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = { Name = "${var.name_prefix}-${each.key}-sg" }
}

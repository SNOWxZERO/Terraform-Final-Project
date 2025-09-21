data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file(var.public_key_path)
  tags = { Name = "${var.name_prefix}-key" }
}


resource "aws_instance" "servers" {
  for_each      = var.instances
  count         = each.value.count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.PubOrPrivSubnet[each.value.subnet_type].id
  vpc_security_group_ids = [aws_security_group.SGs[each.key].id]
  associate_public_ip_address = each.value.associate_public_ip
  key_name      = aws_key_pair.mykey.key_name
  user_data     = each.value.user_data

  tags = {
    Name = "${var.name_prefix}-${each.key}-${count.index + 1}"
  }

  depends_on = [
    aws_security_group.SGs,
    aws_subnet.PubOrPrivSubnet
  ]
}


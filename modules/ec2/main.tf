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
  for_each = var.instances

  ami                    = data.aws_ami.amazon_linux.id
  instance_type         = each.value.instance_type
  key_name              = aws_key_pair.lab_key.key_name
  vpc_security_group_ids = [aws_security_group.SGs[each.value.security_group].id]
  subnet_id             = aws_subnet.PubOrPrivSubnet[each.value.subnet_key].id

  # Dynamic user_data based on server type
  user_data = base64encode(
    each.value.server_type == "proxy" ? 
    templatefile("${path.module}/${each.value.user_data_file}", {
      internal_alb_dns = aws_lb.albs["internal"].dns_name
      server_name      = each.key
    }) : 
    templatefile("${path.module}/${each.value.user_data_file}", {
      server_name = each.key
    })
  )

  tags = {
    Name = "${var.name_prefix}-${each.key}"
    Type = each.value.server_type
  }

  # Remote provisioner (Requirement 4)
  provisioner "remote-exec" {
    inline = [
      "sleep 60",  # Wait for user-data to complete
      "sudo systemctl status nginx",  # Check nginx instead of httpd
      "echo '${each.key} configured successfully with Nginx'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = each.value.server_type == "proxy" ? self.public_ip : self.private_ip
      
      # Use bastion for private instances
      bastion_host        = each.value.server_type == "backend" ? aws_instance.servers["proxy1"].public_ip : null
      bastion_user        = each.value.server_type == "backend" ? "ec2-user" : null
      bastion_private_key = each.value.server_type == "backend" ? file("~/.ssh/id_rsa") : null
      
      timeout = "10m"
    }
  }
}


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
  key_name              = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [for sg_key in each.value.security_group_keys : var.security_group_ids[sg_key]]
  subnet_id             = var.subnet_ids[each.value.subnet_key]

  # Dynamic user_data based on server type
  user_data_base64 = base64encode(templatefile("${path.module}/${each.value.user_data}", {
    server_name = each.key

  }))

  tags = {
    Name = "${var.name_prefix}-${each.key}"
    Type = each.value.server_type
  }

  # Remote provisioner
  provisioner "remote-exec" {
    inline = [
      "sleep 60",
      "sudo systemctl status nginx",
      "echo '${each.key} configured successfully with Nginx'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = each.value.server_type == "proxy" ? self.public_ip : self.private_ip
      
      # Fixed bastion logic:
      bastion_host        = each.value.server_type == "backend" ? aws_instance.servers["proxy1"].public_ip : null
      bastion_user        = each.value.server_type == "backend" ? "ec2-user" : null
      bastion_private_key = each.value.server_type == "backend" ? file(var.private_key_path) : null
      
      timeout = "10m"
    }
  }
}


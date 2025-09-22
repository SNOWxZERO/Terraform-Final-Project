module "vpc" {
  source = "./modules/vpc"
  
  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr
}

module "subnets" {
  source = "./modules/subnet"
  
  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnets     = var.subnets_config
}

module "igw" {
  source = "./modules/igw"
  
  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id 
}

module "security_groups" {
  source = "./modules/security_group"
  
  name_prefix      = var.name_prefix
  vpc_id          = module.vpc.vpc_id
  security_groups = var.security_groups
}

module "nat" {
  source = "./modules/nat"
  
  name_prefix    = var.name_prefix
  subnets        = var.subnets_config
  public_subnets = module.subnets.public_subnet_ids
  igw_id         = module.igw.igw_id
}

module "route_tables" {
  source = "./modules/route_table"
  
  name_prefix     = var.name_prefix
  vpc_id          = module.vpc.vpc_id
  subnets_config  = var.subnets_config
  subnet_ids      = module.subnets.all_subnet_ids
  igw_id          = module.igw.igw_id
  nat_gateway_ids = module.nat.nat_gateway_ids
}

module "ec2" {
  source = "./modules/ec2"
  
  name_prefix        = var.name_prefix
  instances          = var.instances
  subnet_ids        = module.subnets.all_subnet_ids
  security_group_ids = module.security_groups.security_group_ids
  public_key_path   = var.public_key_path
  private_key_path  = var.private_key_path
}

module "alb" {
  source = "./modules/alb"

  name_prefix        = var.name_prefix
  load_balancers     = var.load_balancers
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.subnets.all_subnet_ids
  security_group_ids = module.security_groups.security_group_ids
  instance_ids      = module.ec2.all_instance_ids
  depends_on        = [module.subnets, module.security_groups, module.ec2]
}



# Local exec to create all-ips.txt
resource "null_resource" "generate_ips" {
  depends_on = [module.ec2]

  provisioner "local-exec" {
    command = <<-EOT
      echo "public-ip1 ${module.ec2.instance_summary["proxy1"].public_ip}" > all-ips.txt
      echo "public-ip2 ${module.ec2.instance_summary["proxy2"].public_ip}" >> all-ips.txt
      echo "private-ip1 ${module.ec2.instance_summary["backend1"].private_ip}" >> all-ips.txt
      echo "private-ip2 ${module.ec2.instance_summary["backend2"].private_ip}" >> all-ips.txt
    EOT
  }
}


#this null resource to update the proxy server configuration after the ALB is created
#because at the time of proxy server creation, the ALB DNS is not known
#but we need it to connect to the backend servers through the ALB
resource "null_resource" "update_proxy_config" {
  depends_on = [module.ec2, module.alb]

  # Create one resource for each proxy server
  for_each = {
    for k, v in var.instances : k => v if v.server_type == "proxy"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = module.ec2.instance_summary[each.key].public_ip
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Starting proxy configuration update for ${each.key}...'",
      
      # Check current Nginx status
      "sudo systemctl status nginx --no-pager || echo 'Nginx not running, will start after config update'",
      
      # Backup current config
      "sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup",
      
      # Show current config before replacement
      "echo 'Current upstream config:'",
      "sudo grep -A 3 'upstream backend_servers' /etc/nginx/nginx.conf || echo 'No upstream section found'",
      
      # Perform the replacement
      "echo 'Updating configuration...'",
      "sudo sed -i 's/BACKEND_ALB_PLACEHOLDER/${module.alb.internal_alb_dns}/g' /etc/nginx/nginx.conf",
      
      # Show config after replacement
      "echo 'Updated upstream config:'",
      "sudo grep -A 3 'upstream backend_servers' /etc/nginx/nginx.conf",
      
      # Test configuration before applying
      "echo 'Testing Nginx configuration...'",
      "sudo nginx -t",
      
      # If config test passes, reload/restart Nginx
      "echo 'Configuration test passed, reloading Nginx...'",
      "sudo systemctl stop nginx || echo 'Nginx was not running'",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      
      # Verify Nginx is running
      "sudo systemctl status nginx --no-pager",
      
      # Test the proxy functionality
      "echo 'Testing proxy functionality...'",
      "curl -s http://localhost/health || echo 'Health check failed'",
      
      "echo 'Proxy ${each.key} updated successfully to target: ${module.alb.internal_alb_dns}'"
    ]
  }

  # Trigger update when ALB DNS changes
  triggers = {
    alb_dns     = module.alb.internal_alb_dns
    instance_id = module.ec2.instance_summary[each.key].id
  }
}
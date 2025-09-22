output "workspace_info" {
  description = "Current Terraform workspace information"
  value = {
    current_workspace = terraform.workspace
    environment      = var.name_prefix
    region          = var.aws_region
  }
}

output "Testing_Urls" {
  description = "Testing URLs for the load balancers"
  value = {
    public_alb_url   = module.alb.public_alb_url
    internal_alb_url = module.alb.internal_alb_dns != "" ? "http://${module.alb.internal_alb_dns}" : "No Internal ALB"
    proxy1_direct    = "http://${module.ec2.proxy_public_ips["proxy1"]}"
    proxy2_direct    = "http://${module.ec2.proxy_public_ips["proxy2"]}"
  }
}

output "SSH_Commands" {
  description = "SSH commands to access EC2 instances"
  value = {
    proxy1   = "ssh -i ~/.ssh/mykey ec2-user@${module.ec2.proxy_public_ips["proxy1"]}"
    proxy2   = "ssh -i ~/.ssh/mykey ec2-user@${module.ec2.proxy_public_ips["proxy2"]}"
    backend1 = "ssh -i ~/.ssh/mykey -o ProxyJump=ec2-user@${module.ec2.proxy_public_ips["proxy1"]} ec2-user@${module.ec2.backend_private_ips["backend1"]}"
    backend2 = "ssh -i ~/.ssh/mykey -o ProxyJump=ec2-user@${module.ec2.proxy_public_ips["proxy1"]} ec2-user@${module.ec2.backend_private_ips["backend2"]}"
  }
}
output "public_ips" {
  description = "List of public instance public IPs"
  value       = aws_instance.public[*].public_ip
}

output "public_instance_ids" {
  description = "List of public instance IDs"
  value       = aws_instance.public[*].id
}

output "private_ips" {
  description = "List of private instance private IPs"
  value       = aws_instance.private[*].private_ip
}
output "private_instance_ids" {
  description = "List of private instance IDs"
  value       = aws_instance.private[*].id
}


output "testing_urls" {
  description = "URLs for testing the infrastructure"
  value = {
    main_site           = "http://${aws_lb.albs["public"].dns_name}"
    api_test           = "http://${aws_lb.albs["public"].dns_name}/api/test.html"
    health_check       = "http://${aws_lb.albs["public"].dns_name}/health"
    proxy1_direct      = "http://${aws_instance.servers["proxy1"].public_ip}"
    proxy2_direct      = "http://${aws_instance.servers["proxy2"].public_ip}"
  }
}

output "ssh_commands" {
  description = "SSH commands to connect to instances"
  value = {
    proxy1   = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.servers["proxy1"].public_ip}"
    proxy2   = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.servers["proxy2"].public_ip}"
    backend1 = "ssh -i ~/.ssh/id_rsa -o ProxyJump=ec2-user@${aws_instance.servers["proxy1"].public_ip} ec2-user@${aws_instance.servers["backend1"].private_ip}"
    backend2 = "ssh -i ~/.ssh/id_rsa -o ProxyJump=ec2-user@${aws_instance.servers["proxy1"].public_ip} ec2-user@${aws_instance.servers["backend2"].private_ip}"
  }
}

output "workspace_info" {
  description = "Current Terraform workspace information"
  value = {
    current_workspace = terraform.workspace
    environment      = var.name_prefix
    region          = var.aws_region
  }
}
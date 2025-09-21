output "proxy_public_ips" {
  description = "Public IP addresses of proxy servers"
  value = {
    for k, v in aws_instance.servers : k => v.public_ip
    if contains(["proxy1", "proxy2"], k)
  }
}

output "proxy_instance_ids" {
  description = "Instance IDs of proxy servers"
  value = {
    for k, v in aws_instance.servers : k => v.id
    if contains(["proxy1", "proxy2"], k)
  }
}

# Backend server outputs
output "backend_private_ips" {
  description = "Private IP addresses of backend servers"
  value = {
    for k, v in aws_instance.servers : k => v.private_ip
    if contains(["backend1", "backend2"], k)
  }
}

output "backend_instance_ids" {
  description = "Instance IDs of backend servers"
  value = {
    for k, v in aws_instance.servers : k => v.id
    if contains(["backend1", "backend2"], k)
  }
}


output "instance_summary" {
  description = "Complete summary of all instances"
  value = {
    for k, v in aws_instance.servers : k => {
      id         = v.id
      public_ip  = v.public_ip
      private_ip = v.private_ip
      subnet     = var.instances[k].subnet_key
      type       = var.instances[k].server_type
    }
  }
}

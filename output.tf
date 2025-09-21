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

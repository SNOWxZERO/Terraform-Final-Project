output "security_group_ids" {
  description = "IDs of all security groups"
  value = {
    for k, v in aws_security_group.SGs : k => v.id
  }
}
output "nat_gateway_ids" {
  description = "Map of NAT Gateway IDs"
  value = {
    for k, v in aws_nat_gateway.nat : k => v.id
  }
}

output "eip_ids" {
  description = "Map of Elastic IP IDs"
  value = {
    for k, v in aws_eip.nat-eip : k => v.id
  }
}

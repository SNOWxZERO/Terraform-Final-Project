output "subnet_info" {
  description = "Information about all subnets"
  value = {
    for k, v in aws_subnet.PubOrPrivSubnet : k => {
      id                = v.id
      cidr_block       = v.cidr_block
      availability_zone = v.availability_zone
      type             = var.subnets[k].map_public_ip ? "Public" : "Private"
    }
  }
}

output "all_subnet_ids" {
  description = "Map of all subnet IDs"
  value = {
    for k, v in aws_subnet.PubOrPrivSubnet : k => v.id
  }
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs"
  value = {
    for k, v in aws_subnet.PubOrPrivSubnet : k => v.id
    if var.subnets[k].map_public_ip == true
  }
}

output "private_subnet_ids" {
  description = "Map of private subnet IDs"
  value = {
    for k, v in aws_subnet.PubOrPrivSubnet : k => v.id
    if var.subnets[k].map_public_ip == false
  }
}
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
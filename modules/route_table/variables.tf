variable "name_prefix" {
  type    = string
  default = "Gad-Project-ITI"
  description = "Prefix for resource names"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "igw_id" {
  type        = string
  description = "The ID of the Internet Gateway"
}

variable "nat_gateway_ids" {
  type        = map(string)
  description = "Map of NAT Gateway IDs"
}

variable "subnets_config" {
  description = "Map of subnet configurations"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    map_public_ip     = bool
  }))
}

variable "subnet_ids" {
  description = "Map of actual subnet IDs"
  type        = map(string)
}
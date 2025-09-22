variable "vpc_id" {
  description = "VPC ID where subnets will be created"
  type        = string
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    map_public_ip     = bool
  }))
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "Gad-Project-ITI"
}
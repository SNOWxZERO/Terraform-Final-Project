variable "name_prefix" {
    type    = string
    default = "Gad-Project-ITI"
    description = "Prefix for resource names"
    }

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    map_public_ip     = bool
  }))
}

variable "public_subnets" {
  description = "Map of public subnet IDs"
  type        = map(string)
}

variable "igw_id" {
  description = "Internet Gateway ID"
  type        = string
}
variable "name_prefix" {
  type    = string
  default = "Gad-lab2-ITI"
  description = "Prefix for resource names"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "public_subnet_id" {
  type        = string
  description = "The ID of the public subnet"
}

variable "private_subnet_id" {
  type        = string
  description = "The ID of the private subnet"
}
variable "igw_id" {
  type        = string
  description = "The ID of the Internet Gateway"
}
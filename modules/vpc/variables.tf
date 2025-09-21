variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "name_prefix" {
  type    = string
  default = "Gad-lab2-ITI"
  description = "Prefix for resource names"
}
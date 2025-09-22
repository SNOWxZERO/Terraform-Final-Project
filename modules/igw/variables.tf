variable "name_prefix" {
  type    = string
  default = "Gad-Project-ITI"
  description = "Prefix for resource names"
}

variable "vpc_id" {
  description = "VPC ID where IGW will be attached"
  type        = string
}
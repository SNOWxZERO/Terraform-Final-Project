variable "aws_region" {
  type    = string
  default = "us-east-1"
  description = "AWS region"
}

variable "aws_availability_zone" {
  type    = string
  default = "us-east-1a"
  description = "AWS availability zone"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "subnets" {
  description = "List of subnets to create"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    map_public_ip     = bool
  }))
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "public_instance_count" {
  type    = number
  default = 1
}

variable "private_instance_count" {
  type    = number
  default = 1
}



variable "name_prefix" {
  type    = string
  default = "Gad-lab2-ITI"
  description = "Prefix for resource names"
}



variable "security_groups" {
  description = "Security groups with their rules"
  type = map(object({
    description = string
    ingress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
  }))
}

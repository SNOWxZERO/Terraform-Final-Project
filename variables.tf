variable "name_prefix" {
  type    = string
  default = "Gad-Project-ITI"
  description = "Prefix for resource names"
}

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

variable "subnets_config" {
  description = "List of subnets to create"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    map_public_ip     = bool
  }))
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

variable "load_balancers" {
  description = "Load balancer configurations"
  type = map(object({
    internal         = bool
    subnet_keys      = list(string)
    security_group   = string
    target_instances = list(string)
    target_port      = number
  }))
}

variable "instances" {
  description = "EC2 instance configurations"
  type = map(object({
    instance_type   = string
    subnet_key      = string
    security_group_keys  = list(string)
    server_type     = string
    user_data  = string
  }))
}
variable "public_key_path" {
  description = "Path to the public key for SSH access"
  type        = string
  default     = "C:\\Users\\SNOW\\.ssh\\mykey.pub"
}
variable "private_key_path" {
  description = "Path to the private key for SSH access"
  type        = string
  default     = "C:\\Users\\SNOW\\.ssh\\mykey"
}

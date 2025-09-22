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

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "Gad-Project-ITI"
}

variable "vpc_id" {
  description = "VPC ID where ALB will be created"
  type        = string
}

variable "security_group_ids" {
  description = "Map of security group IDs"
  type        = map(string)
}

variable "subnet_ids" {
  description = "Map of subnet IDs"
  type        = map(string)
}

variable "instance_ids" {
  description = "Map of instance IDs"
  type        = map(string)
}
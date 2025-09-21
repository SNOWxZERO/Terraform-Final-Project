variable "security_groups" {
  description = "Security groups with their rules"
  type = map(object({
    description = string
    ingress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      security_groups = list(string)  
      description = string
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      security_groups = list(string)
      description = string
    }))
  }))
}
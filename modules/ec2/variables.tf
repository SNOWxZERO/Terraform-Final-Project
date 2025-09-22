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

variable "name_prefix" {
  type    = string
  default = "Gad-Project-ITI"
  description = "Prefix for resource names"
}
variable "instances" {
  description = "EC2 instance configurations"
  type = map(object({
    instance_type       = string
    subnet_key          = string
    security_group_keys = list(string)
    user_data           = string
    server_type         = string
  }))
}

variable "subnet_ids" {
  description = "Map of subnet IDs"
  type        = map(string)
}

variable "security_group_ids" {
  description = "Map of security group IDs"
  type        = map(string)
}
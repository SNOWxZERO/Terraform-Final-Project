variable "public_key_path" {
    description = "Path to the public key for SSH access"
    type        = string
    default     = "C:\\Users\\SNOW\\.ssh\\mykey.pub"
    }
variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    default     = "t3.micro"
    }

variable "instances" {
  type = map(object({
    count                  = number
    subnet_type            = string   # "public" or "private"
    associate_public_ip    = bool
    user_data              = string
  }))
}

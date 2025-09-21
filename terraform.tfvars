subnets = {
  public = {
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip     = true
  },
  private = {
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1a" 
    map_public_ip     = false
  }
}

security_groups = {
  public = {
    description = "Public SG"
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH from anywhere"
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "http"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP from anywhere"
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound"
      }
    ]
  }
  private = {
    description = "Private SG"
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"] 
        description = "SSH from VPC"
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound"
      }
    ]
  }
}


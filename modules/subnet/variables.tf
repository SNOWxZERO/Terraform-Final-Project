variable "subnets" {
    description = "A map of subnet configurations"
    type = map(object({
        cidr_block        = string
        availability_zone = string
        map_public_ip     = bool
    }))
    }
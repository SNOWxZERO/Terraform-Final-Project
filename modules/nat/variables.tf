variable "name_prefix" {
    type    = string
    default = "Gad-lab2-ITI"
    description = "Prefix for resource names"
    }

variable "subnets" {
    type        = map(object({
        cidr_block       = string
        map_public_ip    = optional(bool)
    }))
    description = "Map of subnet configurations"
}
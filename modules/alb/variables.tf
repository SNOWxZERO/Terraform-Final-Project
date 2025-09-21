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
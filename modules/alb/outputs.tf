output "public_alb_dns" {
  description = "DNS name of the public load balancer"
  value       = aws_lb.albs["public"].dns_name
}

output "public_alb_url" {
  description = "Full URL of the public load balancer"
  value       = "http://${aws_lb.albs["public"].dns_name}"
}

output "internal_alb_dns" {
  description = "DNS name of the internal load balancer"
  value       = aws_lb.albs["internal"].dns_name
}

output "load_balancer_summary" {
  description = "Complete summary of all load balancers"
  value = {
    for k, v in aws_lb.albs : k => {
      dns_name = v.dns_name
      type     = var.load_balancers[k].internal ? "Internal" : "Public"
      url      = "http://${v.dns_name}"
    }
  }
}

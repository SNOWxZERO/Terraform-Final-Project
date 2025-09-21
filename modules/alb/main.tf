resource "aws_lb" "albs" {
  for_each = var.load_balancers

  name               = "${var.name_prefix}-${each.key}-alb"
  internal           = each.value.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SGs[each.value.security_group].id]
  subnets           = [for subnet_key in each.value.subnet_keys : aws_subnet.PubOrPrivSubnet[subnet_key].id]

  tags = { 
    Name = "${var.name_prefix}-${each.key}-alb"
    Type = each.value.internal ? "Internal" : "Public"
  }
}

# Unified Target Groups using for_each ✅
resource "aws_lb_target_group" "tgs" {
  for_each = var.load_balancers

  name     = "${var.name_prefix}-${each.key}-tg"
  port     = each.value.target_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = { Name = "${var.name_prefix}-${each.key}-tg" }
}

# Unified Target Group Attachments using for_each ✅
resource "aws_lb_target_group_attachment" "attachments" {
  for_each = {
    for pair in flatten([
      for lb_key, lb_config in var.load_balancers : [
        for instance_key in lb_config.target_instances : {
          lb_key       = lb_key
          instance_key = instance_key
        }
      ]
    ]) : "${pair.lb_key}-${pair.instance_key}" => pair
  }

  target_group_arn = aws_lb_target_group.tgs[each.value.lb_key].arn
  target_id        = aws_instance.servers[each.value.instance_key].id
  port             = var.load_balancers[each.value.lb_key].target_port
}

# Unified Load Balancer Listeners using for_each ✅
resource "aws_lb_listener" "listeners" {
  for_each = var.load_balancers

  load_balancer_arn = aws_lb.albs[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tgs[each.key].arn
  }
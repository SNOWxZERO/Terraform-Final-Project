resource "aws_lb" "albs" {
  for_each = var.load_balancers

  name               = "${var.name_prefix}-${each.key}-alb"
  internal           = each.value.internal
  load_balancer_type = "application"
  security_groups    = [var.security_group_ids[each.value.security_group]]
  subnets           = [for subnet_key in each.value.subnet_keys : var.subnet_ids[subnet_key]]

  tags = { 
    Name = "${var.name_prefix}-${each.key}-alb"
    Type = each.value.internal ? "Internal" : "Public"
  }
}

resource "aws_lb_target_group" "tgs" {
  for_each = var.load_balancers

  name     = "${var.name_prefix}-${each.key}-tg"
  port     = each.value.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

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
  target_id        = var.instance_ids[each.value.instance_key]
  port             = var.load_balancers[each.value.lb_key].target_port
}

resource "aws_lb_listener" "listeners" {
  for_each = var.load_balancers

  load_balancer_arn = aws_lb.albs[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tgs[each.key].arn
  }
}
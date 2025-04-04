resource "aws_lb" "webapi" {
  name               = format(local.resource_name, var.public_alb_config.tg_name)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = {
    Name = format(local.resource_name, var.public_alb_config.name)
  }
}

resource "aws_lb_target_group" "webapi" {
  name     = format(local.resource_name, var.public_alb_config.tg_name)
  port     = var.ecs_cluster_config.task_definitions.webapi.container.port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    interval            = 30
    path                = "/swagger/index.html"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = format(local.resource_name, var.public_alb_config.tg_name)
  }
}

resource "aws_lb_listener" "webapi" {
  load_balancer_arn = aws_lb.webapi.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapi.arn
  }
}

resource "aws_autoscaling_attachment" "webapi" {
  autoscaling_group_name = aws_autoscaling_group.webapi_asg.name
  lb_target_group_arn    = aws_lb_target_group.webapi.arn
}

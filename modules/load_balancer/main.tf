locals {
  base_tags = {
    Environment = var.environment
    Creator     = var.prefname
    Purpose     = var.purpose
  }
}

resource "aws_lb" "app" {
  name                       = "${var.prefname}-alb"
  load_balancer_type         = "application"
  internal                   = false
  subnets                    = var.public_subnet_ids
  security_groups            = [var.alb_sg_id]
  enable_deletion_protection = false

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-alb"
  })
}

resource "aws_lb_target_group" "backend" {
  name        = "${var.prefname}-backend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-backend-tg"
  })
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.prefname}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-frontend-tg"
  })
}

resource "aws_autoscaling_attachment" "backend" {
  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.backend.arn
}

resource "aws_autoscaling_attachment" "frontend" {
  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.frontend.arn
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "add_exchange_rate" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/addExchangeRate", "/addExchangeRate/*"]
    }
  }
}

resource "aws_lb_listener_rule" "get_total_count" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/getTotalCount", "/getTotalCount/*"]
    }
  }
}

resource "aws_lb_listener_rule" "get_amount" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/getAmount", "/getAmount/*"]
    }
  }
}

resource "aws_lb_listener_rule" "landing_page" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

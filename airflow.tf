resource "aws_route53_record" "airflow" {
  zone_id = var.route53_zone_public_id
  name    = "airflow"
  type    = "A"

  alias {
    zone_id                = var.alb_public_zone_id
    name                   = var.alb_public_dns_name
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "airflow" {
  name                 = "airflow"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 5

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    path                = "/health"
    protocol            = "HTTP"
  }

  tags = local.tags
}

resource "aws_lb_listener_rule" "airflow" {
  listener_arn = var.alb_public_https_listener_arn

  condition {
    host_header {
      values = ["airflow.${var.public_domain_prefix}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.airflow.arn
  }

  tags = local.tags
}

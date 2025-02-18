resource "aws_lb" "cluster_nlb" {
  name                             = "${var.environment}-${substr(var.cluster_name, 0, 12)}-nlb"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = [var.vpc_subnet.id_a, var.vpc_subnet.id_b]
  enable_cross_zone_load_balancing = true

  tags = {
    Environment = var.environment
    Cluster     = var.cluster_name
    Terraform   = "true"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.cluster_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.cluster_nlb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik.arn
  }
}

resource "aws_lb_target_group" "traefik" {
  name        = "${var.environment}-${substr(var.cluster_name, 0, 12)}-trf"
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Environment = var.environment
    Cluster     = var.cluster_name
    Terraform   = "true"
  }
}

output "nlb_dns_name" {
  description = "The DNS name of the Network Load Balancer"
  value       = aws_lb.cluster_nlb.dns_name
}

output "nlb_arn" {
  description = "The ARN of the Network Load Balancer"
  value       = aws_lb.cluster_nlb.arn
}

output "target_group_arn" {
  description = "The ARN of the Target Group for Traefik"
  value       = aws_lb_target_group.traefik.arn
}

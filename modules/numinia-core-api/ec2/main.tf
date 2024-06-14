resource "aws_security_group" "security_group" {
  vpc_id = var.vpc_id
  name   = "${var.resource_name}-service-security-group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.server_name} security group"
  }
}

resource "aws_security_group" "alb_security_group" {
  vpc_id = var.vpc_id
  name   = "${var.resource_name}-alb-security-group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_name} load balancer security group"
  }
}

resource "aws_lb" "load_balancer" {
  internal           = false
  load_balancer_type = "application"
  name               = "${var.resource_name}-alb"
  subnets = [
    var.vpc_subnet.id_a,
    var.vpc_subnet.id_b,
  ]

  security_groups = [aws_security_group.alb_security_group.id]
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "${var.resource_name}-alb-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    timeout             = 90
    unhealthy_threshold = 10
    interval            = 100
    port                = 8000
    protocol            = "HTTP"
    path                = "/api/v1/monit/health"
  }
}

resource "aws_lb_listener" "lb_listener" {
  port              = 443
  protocol          = "HTTPS"
  load_balancer_arn = aws_lb.load_balancer.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }

  certificate_arn = var.acm_certificate_arn
  ssl_policy      = "ELBSecurityPolicy-2016-08"
}
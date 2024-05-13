resource "aws_security_group" "security_group" {
  vpc_id = var.vpc_id
  name   = "${var.resource_name}-service-security-group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.server_name} security group"
  }
}
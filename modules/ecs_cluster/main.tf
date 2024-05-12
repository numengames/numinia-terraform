resource "aws_ecs_cluster" "cluster" {
  name = "${var.server_name}-cluster"
}
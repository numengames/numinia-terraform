resource "aws_ecs_service" "service" {
  desired_count   = 1
  launch_type     = "FARGATE"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  name            = "${var.resource_name}-service"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  deployment_controller {
    type = "ECS"
  }


  network_configuration {
    subnets = [
      var.vpc_subnet.id_a,
      var.vpc_subnet.id_b,
    ]
    assign_public_ip = true
    security_groups  = [var.security_group_id]
  }

  load_balancer {
    container_port   = 8000
    target_group_arn = var.alb_target_group_arn
    container_name   = "${var.resource_name}-container"
  }
}
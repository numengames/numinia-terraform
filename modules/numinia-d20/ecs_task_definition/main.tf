resource "aws_cloudwatch_log_group" "fargate_log_group" {
  name = "/ecs/${var.resource_name}-fargate-service"
}

resource "aws_cloudwatch_log_stream" "fargate_log_stream" {
  name           = "${var.resource_name}-log-stream"
  log_group_name = aws_cloudwatch_log_group.fargate_log_group.name
}

resource "aws_ecs_task_definition" "task_definition" {
  cpu                = "256"
  memory             = "512"
  network_mode       = "awsvpc"
  execution_role_arn = var.task_role_arn
  task_role_arn      = var.task_role_arn
  family             = "${var.resource_name}-task"

  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      environment = []
      cpu         = 256
      memory      = 512
      essential   = true
      name        = "${var.resource_name}-container"
      image       = "ghcr.io/numengames/numinia-d20:main"
      environmentFiles = [
        {
          type  = "s3"
          value = "arn:aws:s3:::ecs.${var.domain_name}/d20-variables.env"
        }
      ]
      mountPoints = []
      volumesFrom = []
      ulimits     = []
      repositoryCredentials = {
        credentialsParameter = var.github_secret_arn
      }
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          "awslogs-group" : "${aws_cloudwatch_log_group.fargate_log_group.name}",
          "awslogs-stream-prefix" : "fargate-log-stream",
          "awslogs-region" : "eu-west-1"
        }
      }
    }
  ])
}
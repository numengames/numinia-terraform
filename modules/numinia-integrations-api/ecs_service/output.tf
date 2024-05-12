output "service_id" {
  value = aws_ecs_service.service.id
}

output "network_configuration" {
  value = aws_ecs_service.service.network_configuration
}
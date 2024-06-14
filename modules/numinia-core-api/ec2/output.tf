output "target_group_arn" {
  value = aws_lb_target_group.lb_target_group.arn
}

output "security_group_id" {
  value = aws_security_group.security_group.id
}

output "load_balancer_dns_name" {
  value = aws_lb.load_balancer.dns_name
}
output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = aws_security_group.cluster_sg.id
} 
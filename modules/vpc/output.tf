output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value = {
    id_a = aws_subnet.subnet_a.id
    id_b = aws_subnet.subnet_b.id
  }
}

output "cluster_security_group_id" {
  value = module.security_groups.cluster_security_group_id
} 
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_info" {
  value = {
    id_a = aws_subnet.subnet_a.id
    id_b = aws_subnet.subnet_b.id
  }
}
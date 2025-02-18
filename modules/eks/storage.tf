# EFS File System
resource "aws_efs_file_system" "cluster_storage" {
  creation_token = "${var.cluster_name}-storage-efs"
  encrypted      = true

  tags = {
    Name        = "${var.cluster_name}-storage-efs"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Security Group para EFS
resource "aws_security_group" "efs" {
  name        = "${var.cluster_name}-storage-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description = "NFS from EKS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-storage-efs-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Data source para obtener información de la VPC
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Mount targets para EFS
resource "aws_efs_mount_target" "zone_a" {
  file_system_id  = aws_efs_file_system.cluster_storage.id
  subnet_id       = var.vpc_subnet.id_a
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "zone_b" {
  file_system_id  = aws_efs_file_system.cluster_storage.id
  subnet_id       = var.vpc_subnet.id_b
  security_groups = [aws_security_group.efs.id]
}

output "efs_id" {
  value = aws_efs_file_system.cluster_storage.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.cluster_storage.dns_name
} 
# Security Group para EFS
resource "aws_security_group" "efs" {
  name        = "${var.cluster_name}-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description = "NFS from VPC"
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
    Name        = "${var.cluster_name}-efs-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# EFS File System por organización
resource "aws_efs_file_system" "org_storage" {
  for_each = var.organizations

  creation_token = "${var.cluster_name}-${each.key}-efs"
  encrypted      = true

  tags = {
    Name         = "${var.cluster_name}-${each.key}-efs"
    Environment  = var.environment
    ManagedBy    = "terraform"
    Organization = each.key
  }
}

# Mount targets para cada EFS en la zona a
resource "aws_efs_mount_target" "zone_a" {
  for_each = aws_efs_file_system.org_storage

  file_system_id  = each.value.id
  subnet_id       = var.vpc_subnet.id_a
  security_groups = [aws_security_group.efs.id]
}

# Mount targets para cada EFS en la zona b
resource "aws_efs_mount_target" "zone_b" {
  for_each = aws_efs_file_system.org_storage

  file_system_id  = each.value.id
  subnet_id       = var.vpc_subnet.id_b
  security_groups = [aws_security_group.efs.id]
}

# Política de backup para cada EFS
resource "aws_efs_backup_policy" "org_storage" {
  for_each = aws_efs_file_system.org_storage

  file_system_id = each.value.id

  backup_policy {
    status = "ENABLED"
  }
}

# Data source para obtener información de la VPC
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Outputs para los IDs de EFS
output "org_efs_ids" {
  description = "Map of organization names to their EFS IDs"
  value = {
    for org, efs in aws_efs_file_system.org_storage : org => efs.id
  }
}

# Outputs para los DNS names de EFS
output "org_efs_dns_names" {
  description = "Map of organization names to their EFS DNS names"
  value = {
    for org, efs in aws_efs_file_system.org_storage : org => efs.dns_name
  }
}
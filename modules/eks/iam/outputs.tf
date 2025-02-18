# Outputs para roles principales
output "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  value       = aws_iam_role.eks_cluster.arn
}

output "nodes_role_arn" {
  description = "ARN of the IAM role for the EKS worker nodes"
  value       = aws_iam_role.eks_nodes.arn
}

# Outputs para roles de administración
output "admin_role_arn" {
  description = "ARN of the IAM role for Kubernetes administrators"
  value       = aws_iam_role.eks_admin.arn
}

output "viewer_access_key" {
  description = "Access key for the Kubernetes viewer user"
  value       = aws_iam_access_key.k8s_viewer_key.id
  sensitive   = true
}

# Outputs para roles de servicios
output "cluster_autoscaler_role_arn" {
  description = "ARN of the IAM role for Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "efs_csi_role_arn" {
  description = "ARN of the IAM role for EFS CSI driver"
  value       = aws_iam_role.efs_csi_driver.arn
}

output "secret_manager_efs_role_arn" {
  description = "ARN of the IAM role for Secret Manager and EFS access"
  value       = aws_iam_role.secret_manager_efs.arn
}

output "load_balancer_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

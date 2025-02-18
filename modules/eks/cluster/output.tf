output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_security_group_id" {
  description = "ID of the security group for the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "nodes_security_group_id" {
  description = "ID of the security group for the EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "cluster_version" {
  description = "The Kubernetes version of the cluster"
  value       = module.eks.cluster_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = module.eks.cluster_status
}

output "cluster_addons" {
  description = "Status of EKS cluster addons"
  value       = module.eks.cluster_addons
}

output "node_groups" {
  description = "Status and information about EKS managed node groups"
  value       = module.eks.eks_managed_node_groups
}

output "cluster_logging" {
  description = "Enabled logging components in the cluster"
  value       = var.cluster_logging
}

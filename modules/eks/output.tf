# Outputs que exponen la información necesaria del cluster
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.cluster.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.cluster.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.cluster.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.cluster.cluster_oidc_issuer_url
}

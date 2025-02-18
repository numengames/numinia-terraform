# Environment configuration
variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
  default     = "production"
}

# Feature flags
variable "enable_certificate_manager" {
  description = "Feature flag to enable/disable the Certificate Manager modules"
  type        = bool
  default     = false
}

variable "enable_storage" {
  description = "Feature flag to enable/disable the Storage module"
  type        = bool
  default     = false
}

variable "enable_route53" {
  description = "Feature flag to enable/disable Route53 resources"
  type        = bool
  default     = false
}

# AWS Secrets Manager configuration
variable "secret_name" {
  description = "Name of the secret in AWS Secrets Manager"
  type        = string
  default     = "numinia/terraform/production"
}

variable "server_name" {
  description = "Server name"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "cluster_config" {
  description = "Cluster configuration"
  type        = map(string)
}

variable "node_groups" {
  description = "Node groups configuration"
  type        = map(any)
}

variable "organizations" {
  description = "List of organizations that need EFS storage"
  type        = set(string)
}

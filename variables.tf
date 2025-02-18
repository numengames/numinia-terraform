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

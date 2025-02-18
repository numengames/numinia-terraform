variable "domain_name" {
  type        = string
  description = "The domain name to use for bucket names"
}

variable "environment" {
  type        = string
  description = "Environment name for tagging (e.g., production, staging)"
}

variable "project_name" {
  type        = string
  description = "Project name for tagging"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate to use for CloudFront distributions"
} 
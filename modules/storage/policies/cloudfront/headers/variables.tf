variable "policy_name" {
  type        = string
  description = "Name of the CloudFront response headers policy"
}

variable "cors_config" {
  type = object({
    allowed_origins     = list(string)
    allowed_methods     = list(string)
    allowed_headers     = list(string)
    allow_credentials   = bool
  })
  description = "CORS configuration for the policy"
  default = {
    allowed_origins     = ["*"]
    allowed_methods     = ["GET", "HEAD", "OPTIONS"]
    allowed_headers     = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
    allow_credentials   = true
  }
}

variable "custom_headers" {
  type = object({
    header   = string
    value    = string
    override = bool
  })
  description = "Custom headers configuration"
  default     = null
} 
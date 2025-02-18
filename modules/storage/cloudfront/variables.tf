variable "distribution_name" {
  type        = string
  description = "Name of the CloudFront distribution"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the CloudFront distribution"
}

variable "bucket_id" {
  type        = string
  description = "ID of the S3 bucket to use as origin"
}

variable "bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket to use as origin"
}

variable "bucket_domain_name" {
  type        = string
  description = "Domain name of the S3 bucket to use as origin"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate to use for the distribution"
}

variable "default_root_object" {
  type        = string
  description = "Object that CloudFront will return when a viewer requests the root URL"
  default     = "index.html"
}

variable "price_class" {
  type        = string
  description = "Price class for the CloudFront distribution (PriceClass_All, PriceClass_200, PriceClass_100)"
  default     = "PriceClass_100"
}

variable "aliases" {
  type        = list(string)
  description = "List of alternate domain names for the CloudFront distribution"
  default     = []
}

variable "environment" {
  type        = string
  description = "Environment name for tagging"
}

variable "custom_error_responses" {
  type = list(object({
    error_code            = number
    response_code         = number
    response_page_path    = string
    error_caching_min_ttl = number
  }))
  description = "List of custom error responses"
  default = [
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    }
  ]
}
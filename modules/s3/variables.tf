variable "domain_name" {
  type        = string
  description = "The name for ending s3 buckets"
}

variable "account_id" {
  type = string
}

variable "cloudfront" {
  type = object({
    distribution_id           = string
    origin_access_identity_id = string
  })
}
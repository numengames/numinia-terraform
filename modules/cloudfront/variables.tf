variable "domain_name" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "s3" {
  type = object({
    statics_bucket_id                   = string
    statics_bucket_regional_domain_name = string
  })
}
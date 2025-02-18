variable "bucket_id" {
  type        = string
  description = "ID of the S3 bucket to apply the policy to"
}

variable "bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket"
}

variable "cloudfront_oai_arn" {
  type        = string
  description = "ARN of the CloudFront Origin Access Identity"
} 
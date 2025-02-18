variable "policy_name" {
  type        = string
  description = "Name of the CloudFront cache policy"
}

variable "policy_comment" {
  type        = string
  description = "Comment for the CloudFront cache policy"
  default     = "Managed by Terraform"
}

variable "ttl_settings" {
  type = object({
    min_ttl     = number
    default_ttl = number
    max_ttl     = number
  })
  description = "TTL settings for the cache policy"
  default = {
    min_ttl     = 0
    default_ttl = 3600    # 1 hour
    max_ttl     = 86400   # 24 hours
  }
}

variable "cookies_behavior" {
  type        = string
  description = "Determines whether any cookies in viewer requests are included in the cache key and automatically included in requests that CloudFront sends to the origin"
  default     = "none"
}

variable "cookies_to_forward" {
  type        = list(string)
  description = "List of cookie names to forward to the origin"
  default     = []
}

variable "headers_behavior" {
  type        = string
  description = "Determines whether any HTTP headers are included in the cache key and automatically included in requests that CloudFront sends to the origin"
  default     = "none"
}

variable "headers_to_forward" {
  type        = list(string)
  description = "List of header names to forward to the origin"
  default     = []
}

variable "query_strings_behavior" {
  type        = string
  description = "Determines whether any URL query strings in viewer requests are included in the cache key and automatically included in requests that CloudFront sends to the origin"
  default     = "none"
}

variable "query_strings_to_forward" {
  type        = list(string)
  description = "List of query string names to forward to the origin"
  default     = []
} 
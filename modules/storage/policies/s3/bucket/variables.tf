variable "bucket_id" {
  type        = string
  description = "ID of the S3 bucket to apply the policies to"
}

variable "block_public_access" {
  type = object({
    acls             = bool
    policy           = bool
    ignore_acls      = bool
    restrict_buckets = bool
  })
  description = "Configuration for blocking public access"
  default = {
    acls             = true
    policy           = true
    ignore_acls      = true
    restrict_buckets = true
  }
}

variable "enable_versioning" {
  type        = bool
  description = "Whether to enable versioning for the bucket"
  default     = false
}

variable "enable_encryption" {
  type        = bool
  description = "Whether to enable server-side encryption for the bucket"
  default     = true
} 
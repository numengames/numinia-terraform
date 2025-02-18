resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = var.bucket_id

  block_public_acls       = var.block_public_access.acls
  block_public_policy     = var.block_public_access.policy
  ignore_public_acls      = var.block_public_access.ignore_acls
  restrict_public_buckets = var.block_public_access.restrict_buckets
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = var.bucket_id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  count  = var.enable_encryption ? 1 : 0
  bucket = var.bucket_id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
} 
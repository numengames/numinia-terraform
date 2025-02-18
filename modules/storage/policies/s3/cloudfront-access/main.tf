data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "cloudfront_access_policy" {
  bucket = var.bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = var.cloudfront_oai_arn
      },
      Action = ["s3:GetObject"],
      Resource = [
        "${var.bucket_arn}",
        "${var.bucket_arn}/*",
      ],
    }]
  })
} 
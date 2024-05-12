resource "aws_s3_bucket" "ecs_bucket" {
  bucket = "ecs.${var.domain_name}"
}

resource "aws_s3_bucket" "dev_storage_bucket" {
  bucket = "dev-storage.${var.domain_name}"
}

resource "aws_s3_bucket" "storage_bucket" {
  bucket = "storage.${var.domain_name}"
}

resource "aws_s3_bucket" "statics_bucket" {
  bucket = "statics.${var.domain_name}"
}

resource "aws_s3_bucket_policy" "cloudfront_access_statics_bucket_policy" {
  bucket = aws_s3_bucket.statics_bucket.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "s3:GetObject",
      Sid    = "AllowCloudFrontServicePrincipalReadOnly",
      Principal = {
        Service = "cloudfront.amazonaws.com"
      },
      Resource = [
        "${aws_s3_bucket.statics_bucket.arn}",
        "${aws_s3_bucket.statics_bucket.arn}/*",
      ],
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = "arn:aws:cloudfront::${var.account_id}:distribution/${var.cloudfront.distribution_id}"
        }
      }
      }, {
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${var.cloudfront.origin_access_identity_id}"
      },
      Action = ["s3:GetObject"],
      Resource = [
        "${aws_s3_bucket.statics_bucket.arn}",
        "${aws_s3_bucket.statics_bucket.arn}/*",
      ],
    }],
  })
}

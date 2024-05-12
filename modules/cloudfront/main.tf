resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for accessing S3 bucket"
}

resource "aws_cloudfront_distribution" "static_resources_distribution" {
  origin {
    origin_id   = var.s3.statics_bucket_id
    domain_name = var.s3.statics_bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["statics.${var.domain_name}"]

  default_cache_behavior {
    target_origin_id = var.s3.statics_bucket_id
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    error_caching_min_ttl = 5
    response_page_path    = "/404.html"
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Name = "CloudFront Distribution for statics s3 Bucket"
  }
}
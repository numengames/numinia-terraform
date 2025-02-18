# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.distribution_name}"
}

# Políticas de CloudFront
module "cache_policy" {
  source      = "../policies/cloudfront/cache"
  policy_name = "${var.distribution_name}CachePolicy"
}

module "headers_policy" {
  source      = "../policies/cloudfront/headers"
  policy_name = "${var.distribution_name}HeadersPolicy"
}

# Política de acceso de CloudFront a S3
module "s3_cloudfront_access" {
  source             = "../policies/s3/cloudfront-access"
  bucket_id          = var.bucket_id
  bucket_arn         = var.bucket_arn
  cloudfront_oai_arn = aws_cloudfront_origin_access_identity.oai.iam_arn
}

# Distribución CloudFront
resource "aws_cloudfront_distribution" "distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.distribution_name
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.aliases

  origin {
    domain_name = var.bucket_domain_name
    origin_id   = var.bucket_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.bucket_id
    viewer_protocol_policy = "redirect-to-https"
    compress              = true

    cache_policy_id            = module.cache_policy.policy_id
    response_headers_policy_id = module.headers_policy.policy_id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  tags = {
    Name        = var.distribution_name
    Environment = var.environment
    Managed_By  = "Terraform"
  }

  depends_on = [
    module.cache_policy,
    module.headers_policy,
    module.s3_cloudfront_access
  ]
}

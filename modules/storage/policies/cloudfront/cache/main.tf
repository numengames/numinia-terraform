resource "aws_cloudfront_cache_policy" "cache_policy" {
  name        = var.policy_name
  comment     = var.policy_comment
  min_ttl     = var.ttl_settings.min_ttl
  default_ttl = var.ttl_settings.default_ttl
  max_ttl     = var.ttl_settings.max_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = var.cookies_behavior
      cookies {
        items = var.cookies_to_forward
      }
    }

    headers_config {
      header_behavior = var.headers_behavior
      headers {
        items = var.headers_to_forward
      }
    }

    query_strings_config {
      query_string_behavior = var.query_strings_behavior
      query_strings {
        items = var.query_strings_to_forward
      }
    }
  }
} 
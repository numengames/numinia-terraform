resource "aws_cloudfront_response_headers_policy" "security_headers_policy" {
  name = var.policy_name

  cors_config {
    access_control_allow_origins {
      items = var.cors_config.allowed_origins
    }
    access_control_allow_methods {
      items = var.cors_config.allowed_methods
    }
    access_control_allow_headers {
      items = var.cors_config.allowed_headers
    }
    access_control_allow_credentials = var.cors_config.allow_credentials
    origin_override                  = true
  }

  dynamic "custom_headers_config" {
    for_each = var.custom_headers != null ? [1] : []
    content {
      items {
        header   = var.custom_headers.header
        value    = var.custom_headers.value
        override = var.custom_headers.override
      }
    }
  }
}
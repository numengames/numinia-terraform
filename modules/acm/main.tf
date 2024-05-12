terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_acm_certificate" "certificate" {
  validation_method = "EMAIL"
  domain_name       = var.domain_name

  subject_alternative_names = [
    "*.${var.domain_name}",
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "SSL Certificate for ${var.domain_name}"
  }
}
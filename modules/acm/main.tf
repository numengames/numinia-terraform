terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_acm_certificate" "certificate" {
  validation_method         = var.validation_method
  domain_name              = var.domain_name
  subject_alternative_names = length(var.subject_alternative_names) > 0 ? var.subject_alternative_names : ["*.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "SSL Certificate for ${var.domain_name}"
    Environment = terraform.workspace
  }
}

# Validation records for DNS method
resource "aws_route53_record" "validation" {
  for_each = var.validation_method == "DNS" ? {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone[0].zone_id
}

# Data source for Route53 zone (only when using DNS validation)
data "aws_route53_zone" "zone" {
  count = var.validation_method == "DNS" ? 1 : 0
  name  = var.domain_name
}
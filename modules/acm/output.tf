output "acm_certificate_arn" {
  value = aws_acm_certificate.certificate.arn
}

output "acm_validation_record_fqdn" {
  value = [
    for option in aws_acm_certificate.certificate.domain_validation_options : option.resource_record_name
  ]
}

output "acm_validation_records" {
  value = [
    for option in aws_acm_certificate.certificate.domain_validation_options : {
      name  = option.resource_record_name
      type  = option.resource_record_type
      value = option.resource_record_value
    }
  ]
}
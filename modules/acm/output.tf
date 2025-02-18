output "certificate_arn" {
  description = "ARN of the certificate"
  value       = aws_acm_certificate.certificate.arn
}

output "domain_validation_options" {
  description = "Domain validation options for the certificate"
  value       = aws_acm_certificate.certificate.domain_validation_options
}

output "validation_emails" {
  description = "List of email addresses that can be used to validate the certificate (only for EMAIL validation)"
  value       = var.validation_method == "EMAIL" ? aws_acm_certificate.certificate.validation_emails : []
}

output "status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.certificate.status
}

output "validation_method" {
  description = "Validation method used for the certificate"
  value       = aws_acm_certificate.certificate.validation_method
}
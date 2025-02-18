output "distribution_id" {
  value       = aws_cloudfront_distribution.distribution.id
  description = "ID of the CloudFront distribution"
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.distribution.domain_name
  description = "Domain name of the CloudFront distribution"
}

output "origin_access_identity_iam_arn" {
  value       = aws_cloudfront_origin_access_identity.oai.iam_arn
  description = "IAM ARN of the CloudFront origin access identity"
}
output "policy_id" {
  value       = aws_cloudfront_response_headers_policy.security_headers_policy.id
  description = "ID of the CloudFront response headers policy"
}
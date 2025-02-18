output "policy_id" {
  value       = aws_cloudfront_cache_policy.cache_policy.id
  description = "ID of the CloudFront cache policy"
}

output "policy_etag" {
  value       = aws_cloudfront_cache_policy.cache_policy.etag
  description = "Current version of the CloudFront cache policy"
} 
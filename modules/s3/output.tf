output "statics_bucket_regional_domain_name" {
  description = "Export the statics bucket regional domain name"
  value       = aws_s3_bucket.statics_bucket.bucket_regional_domain_name
}

output "statics_bucket_id" {
  description = "Export the statics bucket regional id"
  value       = aws_s3_bucket.statics_bucket.id
}

output "statics_bucket_arn" {
  description = "Export the statics bucket regional arn"
  value       = aws_s3_bucket.statics_bucket.arn
}
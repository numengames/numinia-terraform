output "statics_bucket_id" {
  value       = aws_s3_bucket.statics_bucket.id
  description = "ID of the statics bucket"
}

output "statics_bucket_arn" {
  value       = aws_s3_bucket.statics_bucket.arn
  description = "ARN of the statics bucket"
}

output "statics_bucket_regional_domain_name" {
  value       = aws_s3_bucket.statics_bucket.bucket_regional_domain_name
  description = "Regional domain name of the statics bucket"
}
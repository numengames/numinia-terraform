output "origin_access_identity_id" {
  value = aws_cloudfront_origin_access_identity.oai.id
}

output "distribution_id" {
  value = aws_cloudfront_distribution.static_resources_distribution.id
}
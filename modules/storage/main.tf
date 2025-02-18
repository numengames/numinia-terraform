locals {
  bucket_names = {
    storage = "storage.${var.domain_name}"
    statics = "statics.${var.domain_name}"
    dev     = "dev-storage.${var.domain_name}"
  }
}

# S3 module for all buckets
module "s3" {
  source       = "./s3"
  domain_name  = var.domain_name
  environment  = var.environment
  project_name = var.project_name
}

# CloudFront distribution for statics bucket
module "statics_cloudfront" {
  source              = "./cloudfront"
  domain_name         = var.domain_name
  distribution_name   = "StaticsDistribution"
  environment         = var.environment
  acm_certificate_arn = var.acm_certificate_arn
  bucket_id          = module.s3.statics_bucket_id
  bucket_arn         = module.s3.statics_bucket_arn
  bucket_domain_name = module.s3.statics_bucket_regional_domain_name
  aliases            = ["statics.${var.domain_name}"]
  price_class        = "PriceClass_100"
  
  custom_error_responses = [
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    }
  ]
} 
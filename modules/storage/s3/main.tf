locals {
  bucket_names = {
    ecs     = "ecs1.${var.domain_name}"
    storage = "storage.${var.domain_name}"
    statics = "statics1.${var.domain_name}"
    dev     = "dev-storage.${var.domain_name}"
  }

  common_tags = {
    Managed_By  = "Terraform"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Bucket para logs de acceso
resource "aws_s3_bucket" "access_logs" {
  bucket = "access-logs.${var.domain_name}"
  
  tags = merge(local.common_tags, {
    Name = "S3 Access Logs Bucket"
  })
}

module "access_logs_bucket_policies" {
  source    = "../policies/s3/bucket"
  bucket_id = aws_s3_bucket.access_logs.id
}

# Buckets principales
resource "aws_s3_bucket" "ecs_bucket" {
  bucket = local.bucket_names.ecs
  
  tags = merge(local.common_tags, {
    Name = "ECS Bucket"
  })
}

resource "aws_s3_bucket" "dev_storage_bucket" {
  bucket = local.bucket_names.dev
  
  tags = merge(local.common_tags, {
    Name = "Development Storage Bucket"
  })
}

resource "aws_s3_bucket" "storage_bucket" {
  bucket = local.bucket_names.storage
  
  tags = merge(local.common_tags, {
    Name = "Main Storage Bucket"
  })
}

resource "aws_s3_bucket" "statics_bucket" {
  bucket = local.bucket_names.statics
  
  tags = merge(local.common_tags, {
    Name = "Static Assets Bucket"
  })
}

# Configuración de logging para todos los buckets
resource "aws_s3_bucket_logging" "ecs_logging" {
  bucket = aws_s3_bucket.ecs_bucket.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "ecs/"
}

resource "aws_s3_bucket_logging" "dev_storage_logging" {
  bucket = aws_s3_bucket.dev_storage_bucket.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "dev-storage/"
}

resource "aws_s3_bucket_logging" "storage_logging" {
  bucket = aws_s3_bucket.storage_bucket.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "storage/"
}

resource "aws_s3_bucket_logging" "statics_logging" {
  bucket = aws_s3_bucket.statics_bucket.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "statics/"
}

resource "aws_s3_bucket_lifecycle_configuration" "dev_storage_lifecycle" {
  bucket = aws_s3_bucket.dev_storage_bucket.id

  rule {
    id     = "cleanup_old_files"
    status = "Enabled"

    expiration {
      days = var.dev_storage_retention_days
    }
  }
}

# CORS para bucket statics
resource "aws_s3_bucket_cors_configuration" "statics_cors" {
  bucket = aws_s3_bucket.statics_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = var.allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Políticas básicas para todos los buckets
module "ecs_bucket_policies" {
  source    = "../policies/s3/bucket"
  bucket_id = aws_s3_bucket.ecs_bucket.id
}

module "dev_storage_bucket_policies" {
  source    = "../policies/s3/bucket"
  bucket_id = aws_s3_bucket.dev_storage_bucket.id
}

module "storage_bucket_policies" {
  source    = "../policies/s3/bucket"
  bucket_id = aws_s3_bucket.storage_bucket.id
}

module "statics_bucket_policies" {
  source            = "../policies/s3/bucket"
  bucket_id         = aws_s3_bucket.statics_bucket.id
  enable_versioning = true  # Habilitamos versionado para archivos estáticos
}

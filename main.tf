terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.83.0"
    }
  }

  required_version = ">= 1.7.3"

  backend "s3" {
    bucket         = "numinia-terraform-state"
    key            = "environments/production/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "numinia-terraform-locks"
    encrypt        = true
  }
}

locals {
  # Basic configuration
  us_east_region_name = "us-east-1"
  eu_west_region_name = "eu-west-1"
  environment         = var.environment

  # Common tags
  common_tags = {
    Environment = local.environment
    Project     = "numinia"
    ManagedBy   = "terraform"
  }

  # Base configuration from tfvars
  base_config = {
    server_name  = var.server_name
    domain_name  = var.domain_name
    cluster_name = "${var.server_name}-${local.environment}-eks"
  }

  # Cluster configuration
  cluster_config = var.cluster_config

  # Node groups configuration with merged tags
  node_groups_config = {
    for name, config in var.node_groups : name => merge(config, {
      labels = merge(try(config.labels, {}), local.common_tags)
    })
  }
}

provider "aws" {
  alias  = "us_east"
  region = local.us_east_region_name
}

provider "aws" {
  region = local.eu_west_region_name
}

data "aws_caller_identity" "current" {}

module "certificate_manager_us_east" {
  count             = var.enable_certificate_manager ? 1 : 0
  source            = "./modules/acm"
  validation_method = "EMAIL"
  domain_name       = local.base_config.domain_name
  providers         = { aws = aws.us_east }
}

module "certificate_manager_eu_west" {
  count             = var.enable_certificate_manager ? 1 : 0
  source            = "./modules/acm"
  validation_method = "EMAIL"
  domain_name       = local.base_config.domain_name
}

resource "aws_route53_zone" "route53_domain_zone" {
  count = var.enable_route53 ? 1 : 0
  name  = local.base_config.domain_name
}

module "storage" {
  count        = var.enable_storage ? 1 : 0
  source       = "./modules/storage"
  domain_name  = local.base_config.domain_name
  environment  = local.environment
  project_name = local.base_config.server_name
  acm_certificate_arn = var.enable_certificate_manager ? module.certificate_manager_us_east[0].certificate_arn : null
}

module "production" {
  source = "./environments/production"

  server_name    = local.base_config.server_name
  node_groups    = local.node_groups_config
  cluster_config = local.cluster_config
  cluster_name   = local.base_config.cluster_name
  eu_west_region = local.eu_west_region_name
}

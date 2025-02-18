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

  # Desensitize all configuration values that might be used in for_each
  base_config = {
    server_name  = nonsensitive(local.secrets.server_name)
    domain_name  = nonsensitive(local.secrets.domain_name)
    cluster_name = "${nonsensitive(local.secrets.server_name)}-${local.environment}-eks"
  }

  # Desensitize cluster configuration
  cluster_config = {
    max_cpu     = nonsensitive(local.secrets.cluster_config.max_cpu)
    max_memory  = nonsensitive(local.secrets.cluster_config.max_memory)
    max_pods    = nonsensitive(local.secrets.cluster_config.max_pods)
    max_storage = nonsensitive(local.secrets.cluster_config.max_storage)
  }

  # First, create a non-sensitive version of the node groups map keys
  node_group_names = nonsensitive(keys(local.secrets.node_groups))

  # Then, create the node groups configuration using the non-sensitive keys
  node_groups_config = {
    for name in local.node_group_names : name => {
      name          = name
      instance_type = nonsensitive(local.secrets.node_groups[name].instance_type)
      min_size      = nonsensitive(local.secrets.node_groups[name].min_size)
      max_size      = nonsensitive(local.secrets.node_groups[name].max_size)
      desired_size  = try(nonsensitive(local.secrets.node_groups[name].desired_size), null)
      capacity_type = try(nonsensitive(local.secrets.node_groups[name].capacity_type), "SPOT")
      labels        = merge(
        try(nonsensitive(local.secrets.node_groups[name].labels), {}),
        local.common_tags
      )
      taints = try(nonsensitive(local.secrets.node_groups[name].taints), [])
    }
  }
}

provider "aws" {
  alias  = "us_east"
  region = local.us_east_region_name
}

provider "aws" {
  region = local.eu_west_region_name
}

# Fetch secrets from AWS Secrets Manager
data "aws_secretsmanager_secret" "terraform_secrets" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.terraform_secrets.id
}

locals {
  # Parse secrets from AWS Secrets Manager
  secrets = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)
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

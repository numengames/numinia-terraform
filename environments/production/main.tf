provider "aws" {
  region = var.region
}

module "secrets_manager" {
  source             = "../../modules/secrets-manager"
  github_CI_CD       = var.github_CI_CD
  github_secret_name = var.github_secret_name
}

data "aws_caller_identity" "current" {}

module "s3" {
  source      = "../../modules/s3"
  domain_name = var.domain_name
  account_id  = data.aws_caller_identity.current.account_id
  cloudfront = {
    distribution_id           = module.cloudfront.distribution_id
    origin_access_identity_id = module.cloudfront.origin_access_identity_id
  }
}

module "cloudfront" {
  source              = "../../modules/cloudfront"
  domain_name         = var.domain_name
  acm_certificate_arn = var.acm_certificate_arn.us_east
  s3 = {
    statics_bucket_id                   = module.s3.statics_bucket_id
    statics_bucket_regional_domain_name = module.s3.statics_bucket_regional_domain_name
  }
}

module "iam" {
  source                    = "../../modules/iam"
  server_name               = var.server_name
  statics_bucket_arn        = module.s3.statics_bucket_arn
  github_secret_manager_arn = module.secrets_manager.github_secret_manager_arn
}

module "main_vpc" {
  source = "../../modules/vpc"
  vpc = {
    region         = var.region
    igw_cidr_block = "0.0.0.0/0"
    range          = "10.0.0.0/16"
    subnet_range   = "10.0.1.0/24"
    igw_name       = "${var.server_name}-main-igw"
    name           = "${var.server_name}-main-vpc"
    subnet_name    = "${var.server_name}-main-subnet"
  }
}

module "ecs_cluster" {
  source      = "../../modules/ecs_cluster"
  server_name = var.server_name
}

module "numinia_integrations" {
  source              = "../../modules/numinia-integrations-api"
  server_name         = var.server_name
  domain_name         = var.domain_name
  vpc_id              = module.main_vpc.vpc_id
  vpc_subnet          = module.main_vpc.subnet_info
  cluster_id          = module.ecs_cluster.cluster_id
  acm_certificate_arn = var.acm_certificate_arn.eu_west
  task_role_arn       = module.iam.ecs_task_execution_role_github_arn
  github_secret_arn   = module.secrets_manager.github_secret_manager_arn
}

module "numinia_discord_bots" {
  source              = "../../modules/numinia-discord-bots"
  server_name         = var.server_name
  domain_name         = var.domain_name
  vpc_id              = module.main_vpc.vpc_id
  vpc_subnet          = module.main_vpc.subnet_info
  cluster_id          = module.ecs_cluster.cluster_id
  acm_certificate_arn = var.acm_certificate_arn.eu_west
  task_role_arn       = module.iam.ecs_task_execution_role_github_arn
  github_secret_arn   = module.secrets_manager.github_secret_manager_arn
}

module "numinia_d20" {
  source              = "../../modules/numinia-d20"
  server_name         = var.server_name
  domain_name         = var.domain_name
  vpc_id              = module.main_vpc.vpc_id
  vpc_subnet          = module.main_vpc.subnet_info
  cluster_id          = module.ecs_cluster.cluster_id
  acm_certificate_arn = var.acm_certificate_arn.eu_west
  task_role_arn       = module.iam.ecs_task_execution_role_github_arn
  github_secret_arn   = module.secrets_manager.github_secret_manager_arn
}
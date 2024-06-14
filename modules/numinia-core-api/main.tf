locals {
  current_directory = dirname(abspath(path.module))
}

module "core_api_s3" {
  source                = "./s3"
  domain_name           = var.domain_name
  s3_env_variables_file = "${local.current_directory}/../../cloud/core-api-variables.env"
}

module "core_api_service" {
  source               = "./ecs_service"
  cluster_id           = var.cluster_id
  vpc_subnet           = var.vpc_subnet
  resource_name        = "${var.server_name}-core-api"
  alb_target_group_arn = module.core_api_ec2.target_group_arn
  security_group_id    = module.core_api_ec2.security_group_id
  task_definition_arn  = module.core_api_definition_task.task_definition_arn
}

module "core_api_definition_task" {
  source            = "./ecs_task_definition"
  domain_name       = var.domain_name
  task_role_arn     = var.task_role_arn
  github_secret_arn = var.github_secret_arn
  resource_name     = "${var.server_name}-core-api"
}

module "core_api_ec2" {
  source                            = "./ec2"
  vpc_id                            = var.vpc_id
  vpc_subnet                        = var.vpc_subnet
  server_name                       = var.server_name
  acm_certificate_arn               = var.acm_certificate_arn
  resource_name                     = "${var.server_name}-core-api"
  ecs_service_id                    = module.core_api_service.service_id
  ecs_service_network_configuration = module.core_api_service.network_configuration
}

module "iam" {
  source        = "./iam"
  resource_name = "${var.server_name}-core-api"
}
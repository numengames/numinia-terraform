locals {
  current_directory = dirname(abspath(path.module))
}

module "d20_s3" {
  source                = "./s3"
  domain_name           = var.domain_name
  s3_env_variables_file = "${local.current_directory}/../../cloud/d20-variables.env"
}

module "d20_service" {
  source               = "./ecs_service"
  cluster_id           = var.cluster_id
  vpc_subnet           = var.vpc_subnet
  resource_name        = "${var.server_name}-d20"
  security_group_id    = module.d20_ec2.security_group_id
  task_definition_arn  = module.d20_definition_task.task_definition_arn
}

module "d20_definition_task" {
  source            = "./ecs_task_definition"
  domain_name       = var.domain_name
  task_role_arn     = var.task_role_arn
  github_secret_arn = var.github_secret_arn
  resource_name     = "${var.server_name}-d20"
}

module "d20_ec2" {
  source                            = "./ec2"
  vpc_id                            = var.vpc_id
  vpc_subnet                        = var.vpc_subnet
  server_name                       = var.server_name
  acm_certificate_arn               = var.acm_certificate_arn
  resource_name                     = "${var.server_name}-d20"
  ecs_service_id                    = module.d20_service.service_id
  ecs_service_network_configuration = module.d20_service.network_configuration
}
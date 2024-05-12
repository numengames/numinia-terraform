locals {
  current_directory = dirname(abspath(path.module))
}

module "discord_bots_s3" {
  source                = "./s3"
  domain_name           = var.domain_name
  s3_env_variables_file = "${local.current_directory}/../../cloud/discord-bots-variables.env"
}

module "discord_bots_service" {
  source               = "./ecs_service"
  cluster_id           = var.cluster_id
  vpc_subnet           = var.vpc_subnet
  resource_name        = "${var.server_name}-discord-bots"
  security_group_id    = module.discord_bots_ec2.security_group_id
  task_definition_arn  = module.discord_bots_definition_task.task_definition_arn
}

module "discord_bots_definition_task" {
  source            = "./ecs_task_definition"
  domain_name       = var.domain_name
  task_role_arn     = var.task_role_arn
  github_secret_arn = var.github_secret_arn
  resource_name     = "${var.server_name}-discord-bots"
}

module "discord_bots_ec2" {
  source                            = "./ec2"
  vpc_id                            = var.vpc_id
  vpc_subnet                        = var.vpc_subnet
  server_name                       = var.server_name
  acm_certificate_arn               = var.acm_certificate_arn
  resource_name                     = "${var.server_name}-discord-bots"
  ecs_service_id                    = module.discord_bots_service.service_id
  ecs_service_network_configuration = module.discord_bots_service.network_configuration
}
locals {
  environment_name = "production"
}

module "main_vpc" {
  source = "../../modules/vpc"
  vpc = {
    igw_cidr_block = "0.0.0.0/0"
    range          = "10.0.0.0/16"
    region         = var.eu_west_region
    igw_name       = "${var.server_name}-main-igw"
    name           = "${var.server_name}-main-vpc"
    subnet_name    = "${var.server_name}-main-subnet"
  }
}

module "eks" {
  source = "../../modules/eks"
  vpc_subnet = {
    id_a = module.main_vpc.subnet_ids.id_a
    id_b = module.main_vpc.subnet_ids.id_b
  }
  node_groups    = var.node_groups
  cluster_name   = var.cluster_name
  region         = var.eu_west_region
  cluster_config = var.cluster_config
  vpc_id         = module.main_vpc.vpc_id
  environment    = local.environment_name
}

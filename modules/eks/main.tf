data "aws_caller_identity" "current" {}

# Módulo de IAM
module "iam" {
  source = "./iam"

  environment             = var.environment
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = module.cluster.cluster_oidc_issuer_url
  aws_account_id          = data.aws_caller_identity.current.account_id
}

# Módulo principal de EKS que orquesta los submódulos
module "cluster" {
  source = "./cluster"

  vpc_id           = var.vpc_id
  node_groups      = var.node_groups
  environment      = var.environment
  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  nodes_role_arn   = module.iam.nodes_role_arn
  cluster_role_arn = module.iam.cluster_role_arn
  efs_csi_role_arn = module.iam.efs_csi_role_arn
  subnet_ids       = [var.vpc_subnet.id_a, var.vpc_subnet.id_b]
  aws_account_id   = data.aws_caller_identity.current.account_id

  enable_addons = {
    coredns           = true
    kube_proxy        = true
    vpc_cni           = true
    efs_csi           = true
    secrets_store_csi = false
  }
}
